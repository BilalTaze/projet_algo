import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SuggestedFriendsScreen extends StatefulWidget {
  const SuggestedFriendsScreen({super.key});

  @override
  State<SuggestedFriendsScreen> createState() => _SuggestedFriendsScreenState();
}

class _SuggestedFriendsScreenState extends State<SuggestedFriendsScreen> {
  final storage = const FlutterSecureStorage();
  List suggestions = [];
  Set<int> sentRequests = {};

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/friends/suggestions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() => suggestions = decoded);
    } else {
      setState(() => suggestions = []);
    }
  }

  Future<void> sendFriendRequest(int targetId) async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/friends/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'target_user_id': targetId}),
    );

    if (response.statusCode == 200) {
      setState(() => sentRequests.add(targetId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Suggestions d'amis")),
      body: suggestions.isEmpty
          ? const Center(child: Text('Aucune suggestion pour le moment'))
          : ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final user = suggestions[index];
                final alreadySent = sentRequests.contains(user['id']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade200,
                      child: Text(
                        user['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                    trailing: ElevatedButton(
                      onPressed: alreadySent ? null : () => sendFriendRequest(user['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alreadySent ? Colors.grey : Colors.blue,
                      ),
                      child: Text(alreadySent ? 'Envoyée' : 'Ajouter'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
