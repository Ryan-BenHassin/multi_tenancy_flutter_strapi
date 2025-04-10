import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'storage_service.dart';
import '../providers/user_provider.dart';
import 'http_client.dart';

class AuthService {
  static const String _iosBaseUrl = 'http://127.0.0.1:1337/api';
  static const String _androidBaseUrl = 'http://10.0.2.2:1337/api';
  static final String baseUrl = Platform.isIOS ? _iosBaseUrl : _androidBaseUrl;
  
  final StorageService _storage = StorageService();
  final _httpClient = HttpClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local'),
      body: {
        'identifier': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveUserData(data);
      UserProvider.user = data['user'];
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String firstname, String lastname, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local/register'),
      body: {
        'username': email,
        'email': email,
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveUserData(data);
      return data;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    UserProvider.user = null;
  }

  Future<User> getCurrentUser() async {
    if (UserProvider.user != null) {
      return UserProvider.user!;
    }

    try {
      final response = await _httpClient.get('$baseUrl/users/me');
      final user = User.fromJson(response);
      UserProvider.user = user;
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<String?> getAuthToken() async {
    return _storage.getAuthToken();
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    await _storage.saveAuthToken(data['jwt']);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getAuthToken();
    return token != null;
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    final response = await _httpClient.put(
      '$baseUrl/users/${UserProvider.user!.id}',
      body: userData,
    );
    final updatedUser = User.fromJson(response);
    UserProvider.user = updatedUser;
    return updatedUser;
  }
}
