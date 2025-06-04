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
      appBar: AppBar(
        title: const Text("Tous les utilisateurs"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '🔍 Rechercher un nom ou un email',
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

                if (query.isNotEmpty &&
                    !name.contains(query) &&
                    !email.contains(query)) {
                  return const SizedBox.shrink();
                }

                final alreadySent = sentRequests.contains(u['id']);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        u['name'][0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      u['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(u['email']),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed:
                              alreadySent
                                  ? null
                                  : () => sendFriendRequest(u['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                alreadySent ? Colors.grey : Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Voir'),
                        ),
                      ],
                    ),
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
