import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:projet_algo/screens/user_profil_screen.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final storage = const FlutterSecureStorage();
  final searchController = TextEditingController();
  String query = '';

  List users = [];
  List sentRequests = [];

  Future<void> fetchUsers() async {
    final token = await storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('http://localhost:8000/api/users'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      setState(() => users = json.decode(res.body));
    }
  }

  Future<void> sendFriendRequest(int userId) async {
    final token = await storage.read(key: 'token');
    final res = await http.post(
      Uri.parse('http://localhost:8000/api/friends/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'target_user_id': userId}),
    );

    if (res.statusCode == 200) {
      setState(() => sentRequests.add(userId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Demande envoyée')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tous les utilisateurs")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom ou email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() => query = val.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                final name = u['name'].toString().toLowerCase();
                final email = u['email'].toString().toLowerCase();

                // Filtrer selon la recherche
                if (query.isNotEmpty &&
                    !name.contains(query) &&
                    !email.contains(query)) {
                  return const SizedBox.shrink();
                }

                final alreadySent = sentRequests.contains(u['id']);

                return ListTile(
                  title: Text(u['name']),
                  subtitle: Text(u['email']),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed:
                            alreadySent
                                ? null
                                : () => sendFriendRequest(u['id']),
                        child: Text(alreadySent ? "Envoyée" : "Ajouter"),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(user: u),
                            ),
                          );
                        },
                        child: const Text('Voir'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
