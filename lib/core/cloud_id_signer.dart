import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

import 'platform_environment.dart'
    if (dart.library.io) 'platform_environment_io.dart';

class CloudIdSigner implements zhihu_api.ApiCloudIdProvider {
  CloudIdSigner({MethodChannel? channel})
    : _channel = channel ?? _defaultChannel;

  static const appId = '1355';
  static const appSecret = 'dd49a835-56e7-4a0f-95b5-efd51ea5397f';
  static const oauthAuthorization = 'oauth 8d5227e0aaaa4797a763ac64e0c3b8';
  static const signVersion = '2';
  static const _defaultChannel = MethodChannel(
    'com.zhiyue.client/cloud_id',
  );

  final MethodChannel _channel;

  /// The CloudID device channel is intentionally Android-only.  The Dart
  /// request/signing implementation is shared by every target, but the
  /// optional Android SDK context (OAID, model and local MS-ID) has no
  /// equivalent on desktop or in the browser.  Keeping this check here makes
  /// a desktop guest bootstrap deterministic instead of failing on a missing
  /// platform channel.
  static bool get usesNativeDeviceContext =>
      !kIsWeb &&
      !zhIsFlutterTest &&
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<String> sign({
    required String body,
    required String requestTimestamp,
    String udid = '',
    String fallbackUdid = '',
  }) async {
    // CloudIDHelper.encrypt in the 11.4.0 sample concatenates these values in
    // this exact order, then returns a lowercase HMAC-SHA1 hex digest. The
    // official Java wrapper normalizes the current CloudID to a non-null
    // string before JNI, so its fallback slot is not selected by this call
    // path; keep the named argument only for API compatibility.
    final preimage = '$appId$signVersion$body$udid$requestTimestamp';
    return Hmac(
      sha1,
      utf8.encode(appSecret),
    ).convert(utf8.encode(preimage)).toString();
  }

  @override
  Future<Map<String, Object?>> deviceInfo() async {
    if (!usesNativeDeviceContext) return const {};
    try {
      final raw = await _channel
          .invokeMapMethod<String, Object?>('deviceInfo')
          .timeout(const Duration(seconds: 15));
      return raw == null ? const {} : Map<String, Object?>.from(raw);
    } on MissingPluginException {
      // A desktop/test engine can construct the default signer without the
      // Android host channel.  Device info is optional for the init body, so
      // continue with the audited common fields instead of aborting startup.
      return const {};
    } on PlatformException {
      return const {};
    } on TimeoutException {
      return const {};
    }
  }

  @override
  Future<String> appInfo() async {
    if (!usesNativeDeviceContext) return '';
    try {
      final raw = await _channel
          .invokeMethod<String>('appInfo')
          .timeout(const Duration(seconds: 5));
      return raw?.trim() ?? '';
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    } on TimeoutException {
      return '';
    }
  }

  @override
  Future<String> localMsId() async {
    if (!usesNativeDeviceContext) return '';
    try {
      final raw = await _channel
          .invokeMethod<String>('localMsId')
          .timeout(const Duration(seconds: 5));
      return raw?.trim() ?? '';
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    } on TimeoutException {
      return '';
    }
  }

  static String formEncode(Map<String, Object?> source) {
    final sorted = SplayTreeMap<String, Object?>.of(source);
    final parts = <String>[];
    for (final entry in sorted.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      parts.add(
        '${Uri.encodeQueryComponent(entry.key)}='
        '${Uri.encodeQueryComponent(value.toString())}',
      );
    }
    return parts.join('&');
  }

  static String? wrapCloudIdForHeader(String raw) {
    if (raw.isEmpty) return null;
    var checksum = 0;
    for (final code in raw.codeUnits) {
      checksum = (checksum + code) % ((code % 8) + 4);
    }
    final marker = (checksum + raw.length) % 64;
    final first = marker & 0xff;
    final last = (marker + 1 + first) & 0xff;
    if (first == 0x0a || first == 0x0d || last == 0x0a || last == 0x0d) {
      return null;
    }
    return String.fromCharCode(first) + raw + String.fromCharCode(last);
  }
}
