import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final storage = const FlutterSecureStorage();
  List notifications = [];

  Future<void> fetchNotifications() async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() => notifications = json.decode(response.body));
    } else {
      setState(() => notifications = []);
    }
  }

  Future<void> markNotificationsAsRead() async {
    final token = await storage.read(key: 'token');
    await http.post(
      Uri.parse('http://localhost:8000/api/notifications/mark-as-read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    markNotificationsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body:
          notifications.isEmpty
              ? const Center(child: Text('Aucune notification'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final isRead = notif['isRead'] ?? false;

                  return ListTile(
                    leading: Icon(
                      isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                      color: isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(notif['content']),
                    subtitle: Text(notif['createdAt']),
                  );
                },
              ),
    );
  }
}
