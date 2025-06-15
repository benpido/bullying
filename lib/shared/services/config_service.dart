import 'dart:convert';
import 'package:http/http.dart' as http;

class ConfigService {
  final String baseUrl;

  ConfigService({this.baseUrl = 'http://10.0.2.2:3000'});

  Future<Map<String, dynamic>?> fetch() async {
    try {
      final uri = Uri.parse('$baseUrl/api/config');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}