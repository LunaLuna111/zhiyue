part of '../salt_page.dart';

Map<String, dynamic>? _saltMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, value) => MapEntry(key.toString(), value));
}

Widget _saltHeaderPlaceholder() => Container(
  width: 112,
  height: 150,
  color: ZhPalette.background,
  alignment: Alignment.center,
  child: const Icon(Icons.auto_stories_outlined, size: 30),
);

Widget _saltAuthorAvatarPlaceholder() => Container(
  color: ZhPalette.pressed,
  alignment: Alignment.center,
  child: Icon(
    Icons.person_outline_rounded,
    size: 20,
    color: ZhPalette.subtleInk,
  ),
);

/// The designated 11.4.0 client has two authenticated Salt reader contracts.
/// Direct paid-column/short-story links carry the RSA request key in the
/// `/content` body, while mid/long manuscript catalogs obtain `/code` first
/// and then fetch `manu_core`. Mixing the response halves produces a valid
/// HTTP 200 envelope whose article key cannot be decrypted.
