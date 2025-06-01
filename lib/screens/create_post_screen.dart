import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final contentController = TextEditingController();
  String visibility = 'public';
  final storage = const FlutterSecureStorage();
  String message = '';

  Future<void> submitPost() async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': contentController.text,
        'visibility': visibility,
        'media': null, // géré plus tard
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      setState(() => message = 'Erreur lors de la création du post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Contenu du post'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: visibility,
              onChanged: (value) => setState(() => visibility = value!),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Public')),
                DropdownMenuItem(value: 'friends', child: Text('Amis uniquement')),
                DropdownMenuItem(value: 'private', child: Text('Privé')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submitPost, child: const Text('Publier')),
            if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
