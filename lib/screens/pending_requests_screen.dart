import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final storage = const FlutterSecureStorage();
  List requests = [];

  Future<void> fetchPendingRequests() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/friends/pending'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() => requests = json.decode(response.body));
    } else {
      setState(() => requests = []);
    }
  }

  Future<void> acceptRequest(int friendshipId) async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/friends/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'friendship_id': friendshipId}),
    );

    if (response.statusCode == 200) {
      await fetchPendingRequests(); // Refresh list
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes d’amis')),
      body: requests.isEmpty
          ? const Center(child: Text('Aucune demande en attente'))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final from = request['from'];
                return ListTile(
                  title: Text(from['name']),
                  subtitle: Text(from['email']),
                  trailing: ElevatedButton(
                    onPressed: () => acceptRequest(request['id']),
                    child: const Text('Accepter'),
                  ),
                );
              },
            ),
    );
  }
}
