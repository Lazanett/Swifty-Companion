import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  final TextEditingController _loginController = TextEditingController();

  Future<void> login() async {
  final login = _loginController.text.trim();
  if (login.isEmpty) {
    _showError("Please enter a login 42");
    return;
  }

  setState(() => _loading = true);
  try {
    final token = await AuthService().login();

    if (token != null) {
      final userService = UserService();
      final exists = await userService.userExists(login, token);

      if (exists) {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: {'login': login, 'token': token},
        );
      } else {
        _showError('This login 42 does not exist.');
      }
    } else {
      _showError('Authentication failure');
    }
  } catch (_) {
    _showError('Network or server error');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // padding autour du scroll
            child: Container(
              padding: const EdgeInsets.all(48),
              width: 460,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Swifty Companion',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Login 42',
                      hintText: 'ex: lazanett',
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign in with 42'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
