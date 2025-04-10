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
    try {
      final response = await _httpClient.postWithoutAuth(
        '$baseUrl/auth/local',
        body: {
          'identifier': email,
          'password': password,
        },
      );
      
      await _saveUserData(response);
      return response;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login');
    }
  }

  Future<User> getCompleteUserData() async {
    try {
      final userData = await _httpClient.get('$baseUrl/users/me?populate=*');
      print('Complete user data: $userData'); // For debugging
      final user = User.fromJson(userData);
      UserProvider.user = user;
      return user;
    } catch (e) {
      print('Error getting complete user data: $e');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String firstname, 
      String lastname, String phone, String roleType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/local/register'),
        body: {
          'username': email,
          'email': email,
          'password': password,
          'firstname': firstname,
          'lastname': lastname,
          'phone': phone,
          'roleType': roleType,
        },
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        await _saveUserData(data);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Registration failed: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> createDoctorProfile({
    required int userId,
    required String speciality,
  }) async {
    try {
      await _httpClient.post(
        '$baseUrl/doctors',
        body: {
          'data': {
            'users_permissions_user': userId,
            'speciality': speciality,
          }
        },
      );
    } catch (e) {
      print('Error creating doctor: $e');
      throw Exception('Failed to create doctor profile');
    }
  }

  Future<void> createPatientProfile({
    required int userId,
    required DateTime birthdate,
  }) async {
    try {
      await _httpClient.post(
        '$baseUrl/patients',
        body: {
          'data': {
            'users_permissions_user': userId,
            'birthdate': birthdate.toIso8601String(),
          }
        },
      );
    } catch (e) {
      print('Error creating patient: $e');
      throw Exception('Failed to create patient profile');
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
      final response = await _httpClient.get('$baseUrl/users/me?populate=doctor,patient');
      print('Current user response: $response'); // For debugging
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
