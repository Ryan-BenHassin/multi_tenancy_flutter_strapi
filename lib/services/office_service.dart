import '../models/office.dart';
import 'auth_service.dart';
import 'http_client.dart';

class OfficeService {
  final _httpClient = HttpClient();
  
  Future<List<Office>> fetchOffices() async {
    final data = await _httpClient.get('${AuthService.baseUrl}/offices');
    final offices = (data['data'] as List)
        .map((item) => Office.fromJson(item))
        .toList();
    return offices;
  }
}
