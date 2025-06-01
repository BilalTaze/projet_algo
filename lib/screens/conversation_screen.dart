import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ConversationScreen extends StatefulWidget {
  final int friendId;
  final String friendName;

  const ConversationScreen({super.key, required this.friendId, required this.friendName});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final storage = const FlutterSecureStorage();
  final messageController = TextEditingController();
  List messages = [];

  Future<void> loadMessages() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/messages/${widget.friendId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() => messages = json.decode(response.body));
    }
  }

  Future<void> sendMessage() async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'receiver_id': widget.friendId,
        'content': messageController.text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      messageController.clear();
      await loadMessages();
    }
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Discussion avec ${widget.friendName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final fromMe = msg['from'] != widget.friendId;
                return Align(
                  alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: fromMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['content']),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: messageController, decoration: const InputDecoration(hintText: 'Message...')),
              ),
              IconButton(onPressed: sendMessage, icon: const Icon(Icons.send)),
            ],
          ),
        ],
      ),
    );
  }
}
