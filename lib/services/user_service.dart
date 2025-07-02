import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class UserService {
  final String baseUrl = 'https://api.intra.42.fr/v2';
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> fetchUserInfo(String login) async {
    final url = '$baseUrl/users/$login';

    //print("url ${url}");
   //regex
    try {
      final response = await _api.getWithAuth(url); // 2 call ApiService

      if (response == null) return null;

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('User not found');
        return null;
      } else {
        print('API error: code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Unknown error fetchUserInfo: $e');
      return null;
    }
  }

  Future<bool> userExists(String login) async {
    final url = '$baseUrl/users/$login';

    try {
      final response = await _api.getWithAuth(url);

      if (response == null) return false;

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        print('API error : ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Unknown error userExists: $e');
      return false;
    }
  }
}
