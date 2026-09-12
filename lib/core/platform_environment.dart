/// Environment flags that are available without importing a platform SDK.
///
/// The IO implementation adds the Flutter test runner check.  Keeping this
/// file free of `dart:io` lets the same cache code compile for the browser.
bool get zhIsFlutterTest => false;
