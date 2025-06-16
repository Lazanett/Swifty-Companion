import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails')),
      body: const Center(
        child: Text(
          'Bienvenue dans l’écran des détails',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
