import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationCenterPage extends StatefulWidget {
  final String phone, username, email, password;
  const NotificationCenterPage({super.key, required this.phone, required this.username, required this.email, required this.password});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}/notifications');
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value is Map) {
      final notifMap = Map<String, dynamic>.from(snapshot.value as Map);
      notifications = notifMap.values.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      notifications.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    } else {
      notifications = [];
    }
    setState(() { isLoading = false; });
  }

  void markAsRead(int index) async {
    // Optionally update Firebase to mark as read
    setState(() {
      notifications[index]['read'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return ListTile(
                      leading: Icon(
                        notif['read'] == true ? Icons.notifications_none : Icons.notifications,
                        color: notif['read'] == true ? Colors.grey : Colors.indigo,
                      ),
                      title: Text(notif['title'] ?? 'Notification'),
                      subtitle: Text(notif['body'] ?? ''),
                      trailing: Text(
                        notif['timestamp'] != null ? notif['timestamp'].toString().substring(0, 16) : '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () => markAsRead(index),
                    );
                  },
                ),
    );
  }
} 