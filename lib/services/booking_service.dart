import 'auth_service.dart';
import 'http_client.dart';

class BookingService {
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_CONFIRMED = 'CONFIRMED';
  static const String STATUS_CANCELED = 'CANCELED';
  static const String STATUS_REJECTED = 'REJECTED';

  final _httpClient = HttpClient();

  Future<List<DateTime>> fetchAvailableDatetimes(String officeId) async {
    final response = await _httpClient.get('${AuthService.baseUrl}/available-datetimes/$officeId');
    List<dynamic> data = response['data'] ?? [];
    return data.map((dateStr) => DateTime.parse(dateStr.toString())).toList();
  }

  Future<bool> createReservation({
    required int userID,
    required String officeId,
    required DateTime dateTime
  }) async {
    try {
      await _httpClient.post(
        '${AuthService.baseUrl}/reservations',
        body: {
          'data': {
            'date': dateTime.toUtc().toIso8601String(),
            'office': {'id': officeId},
            'user': {'id': userID},
          }
        },
      );
      return true;
    } catch (e) {
      print('Error creating reservation: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBookings({required int userID}) async {
    final data = await _httpClient.get(
      '${AuthService.baseUrl}/reservations?populate=office&filters[user][id][\$eq]=$userID'
    );
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }

  Future<bool> cancelReservation(String reservationId) async {
    try {
      await _httpClient.put(
        '${AuthService.baseUrl}/reservations/$reservationId',
        body: {
          'data': {
            'state': 'CANCELED'
          }
        },
      );
      return true;
    } catch (e) {
      print('Error canceling reservation: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctorBookings(String doctorId) async {
    try {
      final response = await _httpClient.get(
        '${AuthService.baseUrl}/appointments?populate=*&filters[office][doctor][documentId][\$eq]=$doctorId'
      );
      
      if (response['data'] == null) return [];
      
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      return [];
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _httpClient.put(
        '${AuthService.baseUrl}/appointments/$appointmentId',
        body: {
          'data': {
            'status_appointment': status
          }
        },
      );
      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }
}
