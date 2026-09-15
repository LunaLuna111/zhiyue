#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

flutter_bin="${FLUTTER_BIN:-flutter}"
version_name="$(sed -n "s/^const zhiyueVersionName = '\([^']*\)';$/\1/p" lib/core/app_version.dart)"
version_code="$(sed -n 's/^const zhiyueAndroidVersionCode = \([0-9][0-9]*\);$/\1/p' lib/core/app_version.dart)"
manifest_version="$(sed -n 's/^version: *\([0-9][^+[:space:]]*\).*$/\1/p' pubspec.yaml)"

test -n "$version_name"
test -n "$version_code"
test "$manifest_version" = "$version_name"

"$flutter_bin" pub get

# Flutter's generated plugin registrant lives outside the application package
# and otherwise keeps its absolute build path as a source URI in libapp.so.
# Give that generated directory a temporary package mapping before compiling.
# The mapping is generated after pub get and is ignored with the rest of
# .dart_tool; it is never part of the application source or Git index.
package_config="$project_root/.dart_tool/package_config.json"
test -f "$package_config"
if ! grep -Fq '"name": "zhiyue_generated"' "$package_config"; then
  perl -0pi -e 's{(    \{\n      "name": "zhiyue_client",)}{    {\n      "name": "zhiyue_generated",\n      "rootUri": "flutter_build/",\n      "packageUri": "./",\n      "languageVersion": "3.12"\n    },\n$1}' "$package_config"
fi
grep -Fq '"name": "zhiyue_generated"' "$package_config"

"$flutter_bin" build apk \
  --no-pub \
  --release \
  --target-platform android-arm64 \
  --build-name "$version_name" \
  --build-number "$version_code" \
  --obfuscate \
  --split-debug-info=build/symbols/arm64-release \
  --tree-shake-icons \
  "$@"
