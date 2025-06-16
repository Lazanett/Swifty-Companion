import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://api.intra.42.fr/v2';

  Future<Map<String, dynamic>?> fetchUserInfo(String login, String token) async {
    final url = Uri.parse('$baseUrl/users/$login');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('User not found');
        return null;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Invalid or expired token');
        return null;
      } else {
        print('API error: code ${response.statusCode}');
        return null;
      }
    } on SocketException {
      print('No internet connection');
      return null;
    } on TimeoutException {
      print('Timeout exceeded');
      return null;
    } catch (e) {
      print('Unknown error fetchUserInfo: $e');
      return null;
    }
  }

  Future<bool> userExists(String login, String token) async {
    final url = Uri.parse('$baseUrl/users/$login');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Invalid or expired token');
        return false;
      } else {
        print('API error : ${response.statusCode}');
        return false;
      }
    } on SocketException {
      print('No internet connection');
      return false;
    } on TimeoutException {
      print('Timeout exceeded');
      return false;
    } catch (e) {
      print('Unknown error fetchUserInfo: $e');
      return false;
    }
  }
}
