import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = '';

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() => message = 'Inscription réussie. Connectez-vous.');
      await Future.delayed(const Duration(seconds: 10));
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } else {
      final error = json.decode(response.body);
      setState(() => message = error['error'] ?? 'Erreur inconnue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("S'inscrire")),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(message, style: const TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}
