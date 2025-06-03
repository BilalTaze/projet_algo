import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final Map user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil de ${user['name']}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${user['name']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Email : ${user['email']}", style: const TextStyle(fontSize: 16)),
            // Tu peux ajouter + de détails ici si tu les exposes dans ton backend
          ],
        ),
      ),
    );
  }
}
