import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<Map<String, String>> getMultipartHeaders() async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, 
    {bool includeAuth = true}
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<File>? files,
    String fileFieldName,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      
      // Add headers
      request.headers.addAll(await getMultipartHeaders());
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add files
      if (files != null) {
        for (var file in files) {
          request.files.add(await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred');
    }
  }
}
