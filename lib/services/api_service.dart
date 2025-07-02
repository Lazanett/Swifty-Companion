import 'package:http/http.dart' as http;
import 'auth_service.dart';

// Token is valid or not at that moment.
class ApiService {
  final AuthService _auth = AuthService();

  Future<http.Response?> getWithAuth(String url) async {
    String? token = await _auth.getValidToken(); // gettoken 
    if (token == null) return null;

    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      token = await _auth.login();
      if (token == null) return null;

      response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    return response;
  }
}
