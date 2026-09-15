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

"$flutter_bin" build apk \
  --release \
  --target-platform android-arm64 \
  --build-name "$version_name" \
  --build-number "$version_code" \
  --obfuscate \
  --split-debug-info=build/symbols/arm64-release \
  --tree-shake-icons \
  "$@"
