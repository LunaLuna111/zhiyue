import 'package:flutter/services.dart';
import 'package:zhihu_api/zhihu_api.dart' as zhihu_api;

class EndpointContract {
  const EndpointContract({
    required this.role,
    required this.method,
    required this.path,
    required this.origin,
  });

  final String role;
  final String method;
  final String path;
  final String origin;
}

class ApiContract {
  ApiContract._(this.endpoints);

  final Map<String, EndpointContract> endpoints;

  static Future<ApiContract> load() async {
    final source = await rootBundle.loadString('assets/api_contract.json');
    final parsed = zhihu_api.ApiContract.fromJsonString(source);
    final values = <String, EndpointContract>{};
    for (final entry in parsed.endpoints.entries) {
      final role = entry.key;
      final value = entry.value;
      values[role] = EndpointContract(
        role: role,
        method: value.method,
        path: value.path,
        origin: value.origin,
      );
    }
    return ApiContract._(Map.unmodifiable(values));
  }

  EndpointContract operator [](String role) {
    final endpoint = endpoints[role];
    if (endpoint == null) throw StateError('contract role not found: $role');
    return endpoint;
  }
}
