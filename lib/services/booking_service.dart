import 'auth_service.dart';
import 'http_client.dart';

class BookingService {
  final _httpClient = HttpClient();

  Future<List<DateTime>> fetchAvailableDatetimes(String officeId) async {
    final response = await _httpClient.get('${AuthService.baseUrl}/available-datetimes/$officeId');
    List<dynamic> data = response['data'] ?? [];
    return data.map((dateStr) => DateTime.parse(dateStr.toString())).toList();
  }

  Future<bool> createReservation({
    required int userID,
    required int officeId,
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
}
