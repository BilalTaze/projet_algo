import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projet_algo/screens/all_users_screen.dart';
import 'dart:convert';

import 'package:projet_algo/screens/create_post_screen.dart';
import 'package:projet_algo/screens/friends_screen.dart';
import 'package:projet_algo/screens/pending_requests_screen.dart';
import 'package:projet_algo/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  List posts = [];

  Future<void> fetchPosts() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/posts'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() => posts = json.decode(response.body));
    } else {
      setState(() => posts = []);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil d’actualité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            tooltip: 'Demandes reçues',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PendingRequestsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Mes amis',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Mon profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Utilisateurs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllUsersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              final storage = FlutterSecureStorage();
              await storage.delete(key: 'token');
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          ).then((_) => fetchPosts());
        },
        child: const Icon(Icons.add),
      ),
      body:
          posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    child: ListTile(
                      title: Text(post['author'] ?? ''),
                      subtitle: Text(post['content']),
                      trailing: Text(post['visibility']),
                    ),
                  );
                },
              ),
    );
  }
}
