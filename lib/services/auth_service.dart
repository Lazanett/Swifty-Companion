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

  // Stocke token + expiry
  Future<void> _saveToken(String token, int expiresIn) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'expiry', value: expiry.toIso8601String());
  }

  // Récupère token en vérifiant expiration
  Future<String?> getToken() async {
    final token = await _storage.read(key: 'access_token');
    final expiryStr = await _storage.read(key: 'expiry');
    if (token != null && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isBefore(expiry)) {
        // Token valide
        return token;
      }
    }
    // Token absent ou expiré, on récupère un nouveau token
    return await login();
  }

  Future<String?> login() async {
    try {
      final response = await _helper.getToken();
      final token = response?.accessToken;
      final expiresIn = response?.expiresIn ?? 7200; // fallback 2h

      if (token != null) {
        await _saveToken(token, expiresIn);
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
}
