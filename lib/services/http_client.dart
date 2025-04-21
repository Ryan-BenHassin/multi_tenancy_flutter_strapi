import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';

class HttpClient {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      
      print('Response for $url: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded ?? {};
      }
      throw Exception('Request failed with status: ${response.statusCode}');
    } catch (e) {
      print('HTTP GET Error: $e');
      return {};
    }
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Request failed with status: ${response.statusCode}');
  }

  Future<dynamic> postWithoutAuth(String url, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? json.encode(body) : null,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Request failed with status: ${response.statusCode}');
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Request failed with status: ${response.statusCode}');
  }
}
