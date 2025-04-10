import '../models/complex.dart';
import 'auth_service.dart';
import 'http_client.dart';

class ComplexService {
  final _httpClient = HttpClient();
  
  Future<List<Complex>> fetchComplexes() async {
    final data = await _httpClient.get('${AuthService.baseUrl}/complexes');
    final complexes = (data['data'] as List)
        .map((item) => Complex.fromJson(item))
        .toList();
    return complexes;
  }
}
