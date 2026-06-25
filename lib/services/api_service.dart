import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.backendBaseUrl;
  static Duration get timeout => AppConfig.apiTimeout;

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Out of coverage area',
          statusCode: 422,
          code: errorBody['code'] ?? 'OUT_OF_COVERAGE',
        );
      } else if (response.statusCode == 502) {
        throw ApiException(
          message: 'Service temporarily unavailable',
          statusCode: 502,
          code: 'UPSTREAM_ERROR',
        );
      } else {
        throw ApiException(
          message: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        isNetworkError: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<dynamic>> post(
    String endpoint, {
    required dynamic body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          message: errorBody['message'] ?? 'Out of coverage area',
          statusCode: 422,
          code: errorBody['code'] ?? 'OUT_OF_COVERAGE',
        );
      } else if (response.statusCode == 502) {
        throw ApiException(
          message: 'Service temporarily unavailable',
          statusCode: 502,
          code: 'UPSTREAM_ERROR',
        );
      } else {
        throw ApiException(
          message: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        isNetworkError: true,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final bool isNetworkError;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}

