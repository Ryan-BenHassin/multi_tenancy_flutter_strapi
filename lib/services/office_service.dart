import '../models/office.dart';
import 'auth_service.dart';
import 'http_client.dart';

class OfficeService {
  final _httpClient = HttpClient();
  final String _baseUrl = 'http://10.0.2.2:1337/api'; // Update with your Strapi URL

  Future<List<Office>> getDoctorOffices(String doctorId) async {
    try {
      final response = await _httpClient.get('$_baseUrl/offices?filters[doctor][documentId][\$eq]=$doctorId&populate=*');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Office.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching offices: $e');
      return [];
    }
  }

  Future<List<Office>> fetchOffices() async {
    try {
      final response = await _httpClient.get('$_baseUrl/offices');
      if (response['data'] == null) return [];
      
      final List<dynamic> data = response['data'];
      return data.map((json) => Office.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching offices: $e');
      return [];
    }
  }

  Future<Office> createOffice({
    required String title,
    required String description,
    required double longitude,
    required double latitude,
    required String doctorId,
  }) async {
    try {
      final response = await _httpClient.post(
        '$_baseUrl/offices',
        body: {
          'data': {
            'title': title,
            'description': description,
            'longitude': longitude,
            'latitude': latitude,
            'doctor': doctorId,
          }
        },
      );
      return Office.fromJson(response['data']);
    } catch (e) {
      print('Error creating office: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctorBookings(String doctorId) async {
    try {
      final response = await _httpClient.get(
        '${AuthService.baseUrl}/bookings?populate=*&filters[office][doctor][documentId][\$eq]=$doctorId'
      );
      
      if (response == null || response['data'] == null) return [];
      
      return List<Map<String, dynamic>>.from(response['data'].map((item) {
        if (item == null) return {};
        return {
          'documentId': item['documentId'],
          'date': item['date'],
          'status_booking': item['status_booking'],
          'office': item['office'] ?? {},
          'patient': item['patient'] ?? {},
        };
      }));
    } catch (e) {
      print('Error fetching doctor bookings: $e');
      return [];
    }
  }
}
