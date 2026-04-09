import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final notifications = app.notificationsFor(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => app.markAllRead(role),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(item.read ? Icons.drafts : Icons.notifications)),
                  title: Text(item.title),
                  subtitle: Text(item.body),
                  trailing: Text(
                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            ),
    );
  }
}
