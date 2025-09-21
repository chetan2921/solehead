import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'firebase_service.dart';

class ApiService {
  static final Dio _dio = Dio();

  // Get headers with Firebase token
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    Map<String, String> headers = Map.from(ApiConstants.headers);

    // Remove development headers for production backend
    // headers.addAll(ApiConstants.devHeaders);

    if (includeAuth) {
      try {
        final token = await FirebaseService.getIdToken();
        print(
          'API Service: Retrieved token: ${token != null ? "Token found (${token.length} chars)" : "No token"}',
        );
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('API Service: Authorization header added');
        } else {
          print('API Service: No valid token available for authentication');
        }
      } catch (e) {
        print('Error getting auth token: $e');
        // Continue without auth header if token retrieval fails
      }
    }

    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);

      Uri uri = Uri.parse(endpoint);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.delete(Uri.parse(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file with Dio
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    Map<String, dynamic>? additionalFields,
    bool requireAuth = true,
    String fieldName = 'file',
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);

      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
        ...?additionalFields,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Upload failed',
          statusCode: response.statusCode!,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body);
        return decoded;
      } catch (e) {
        print('API Response - JSON Decode Error: $e');
        return {'message': 'Success', 'data': response.body};
      }
    } else {
      String message = 'Request failed';

      // Handle specific status codes
      switch (response.statusCode) {
        case 403:
          message =
              'Access forbidden. Backend server may not be running or configured properly.';
          break;
        case 404:
          message =
              'Endpoint not found. Please check the server configuration.';
          break;
        case 500:
          message = 'Internal server error. Please try again later.';
          break;
        case 401:
          message = 'Authentication failed. Please check your credentials.';
          break;
        default:
          try {
            final errorBody = jsonDecode(response.body);
            message = errorBody['message'] ?? message;
          } catch (e) {
            message = response.body.isNotEmpty ? response.body : message;
          }
      }

      throw ApiException(message: message, statusCode: response.statusCode);
    }
  }

  // Handle errors
  static Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiException(message: 'No internet connection', statusCode: 0);
    } else if (error is DioException) {
      return ApiException(
        message: error.message ?? 'Network error',
        statusCode: error.response?.statusCode ?? 0,
      );
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(message: error.toString(), statusCode: 0);
    }
  }
}

// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
