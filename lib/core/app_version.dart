/// Single source of truth for the client-facing application version.
///
/// Android still receives a numeric versionCode at build time because the
/// package manager requires one. It is derived from the semantic version, not
/// from a build counter, so the public package name remains the semantic
/// version declared below.
library;

const zhiyueVersionName = '0.4.2';
const zhiyueAndroidVersionCode = 4002;

int androidVersionCodeFor(String versionName) {
  final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(versionName);
  if (match == null) return 0;
  final major = int.tryParse(match.group(1)!) ?? 0;
  final minor = int.tryParse(match.group(2)!) ?? 0;
  final patch = int.tryParse(match.group(3)!) ?? 0;
  final value = major * 1000000 + minor * 1000 + patch;
  return value > 0 && value <= 2100000000 ? value : 0;
}
