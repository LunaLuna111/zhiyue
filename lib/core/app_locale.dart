import 'dart:ui';

/// The user-selectable application locales.
///
/// The default is deliberately Simplified Chinese rather than the device
/// locale so a fresh install keeps the product's original language. The
/// preference is stored as [storageValue], never as a localized display name.
enum ZhLocale {
  simplifiedChinese('zh', Locale('zh'), '简体中文'),
  traditionalChinese('zh_TW', Locale('zh', 'TW'), '繁體中文'),
  english('en', Locale('en'), 'English'),
  japanese('ja', Locale('ja'), '日本語'),
  korean('ko', Locale('ko'), '한국어');

  const ZhLocale(this.storageValue, this.locale, this.nativeName);

  final String storageValue;
  final Locale locale;
  final String nativeName;

  static ZhLocale fromStorage(String? value) => switch (value) {
    'zh_TW' => ZhLocale.traditionalChinese,
    'en' => ZhLocale.english,
    'ja' => ZhLocale.japanese,
    'ko' => ZhLocale.korean,
    _ => ZhLocale.simplifiedChinese,
  };
}
