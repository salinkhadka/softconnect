import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:softconnect/features/notification/presentation/view_model/notification_viewmodel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndNotifications();
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = 'http://10.0.2.2:2000';
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  Future<void> _loadUserIdAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      context.read<NotificationViewModel>().loadNotifications(userId);
    }
  }

  Future<void> _refresh() async {
    if (_userId != null) {
      await context.read<NotificationViewModel>().loadNotifications(_userId!);
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationViewModel, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return const Center(child: Text('No notifications'));
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Notification?'),
                              content: const Text(
                                  'Are you sure you want to delete this notification?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) {
                      if (_userId != null) {
                        context
                            .read<NotificationViewModel>()
                            .deleteNotification(notification.id, _userId!);
                      }
                    },
                    child: Card(
                      elevation: notification.isRead ? 0 : 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: notification.isRead
                          ? Colors.white
                          : Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: (notification.sender.profilePhoto !=
                                      null &&
                                  notification.sender.profilePhoto!.isNotEmpty)
                              ? NetworkImage(getFullImageUrl(
                                  notification.sender.profilePhoto))
                              : const AssetImage(
                                      'assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'From: ${notification.sender.username} · Type: ${notification.type}\n${_formatDate(notification.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        trailing: Icon(
                          notification.isRead
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread,
                          color:
                              notification.isRead ? Colors.green : Colors.blue,
                        ),
                        onTap: () {
                          if (!notification.isRead && _userId != null) {
                            context
                                .read<NotificationViewModel>()
                                .markNotificationRead(
                                    notification.id, _userId!);
                          }
                          // Optional: navigate to related content here
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
