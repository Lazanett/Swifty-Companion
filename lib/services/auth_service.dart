import 'dart:io';
import 'dart:async';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final OAuth2Client _client = OAuth2Client(
    authorizeUrl: '',
    tokenUrl: 'https://api.intra.42.fr/oauth/token',
    redirectUri: '',
    customUriScheme: '',
  );

  late final OAuth2Helper _helper = OAuth2Helper(
    _client,
    grantType: OAuth2Helper.clientCredentials,
    clientId: dotenv.env['CLIENT_ID']!,
    clientSecret: dotenv.env['CLIENT_SECRET']!,
    scopes: ['public'],
  );

  final _storage = const FlutterSecureStorage();

  Future<String?> login() async {
    try {
      final response = await _helper.getToken();
      final token = response?.accessToken;
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
        return token;
      } else {
        print('Token null received');
      }
    } on SocketException {
      print('No internet connection (auth)');
    } on TimeoutException {
      print('Auth server connection expired');
    } catch (e) {
      print('Error AuthService.login : $e');
    }
    return null;
  }

  Future<String?> getToken() => _storage.read(key: 'access_token');
}
