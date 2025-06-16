import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://api.intra.42.fr/v2';

  Future<Map<String, dynamic>?> fetchUserInfo(String login, String token) async {
    final url = Uri.parse('$baseUrl/users/$login');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // final json = jsonDecode(response.body);
      // print('📦 JSON complet reçu :\n$json'); // ⬅️ ICI !
      // return json;
      return jsonDecode(response.body);
    } else {
      print('API error : code ${response.statusCode}');
      return null;
    }
  }
}
