import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/notification/presentation/view_model/notification_viewmodel.dart';
import 'package:softconnect/core/utils/getFullImageUrl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  String? _userId;
  final Set<String> _processingNotifications = {};
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserIdAndNotifications();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    const baseUrl = ApiEndpoints.serverAddress;
    return imagePath.startsWith('http')
        ? imagePath
        : '$baseUrl/${imagePath.replaceAll("\\", "/")}';
  }

  Future<void> _loadUserIdAndNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null && mounted) {
        setState(() {
          _userId = userId;
        });
        await context.read<NotificationViewModel>().loadNotifications(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    if (_userId != null) {
      _refreshController.forward();
      try {
        await context.read<NotificationViewModel>().loadNotifications(_userId!);
      } finally {
        _refreshController.reverse();
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    if (_userId != null && !_processingNotifications.contains(notificationId)) {
      setState(() {
        _processingNotifications.add(notificationId);
      });
      try {
        await context.read<NotificationViewModel>().markNotificationRead(notificationId, _userId!);
      } finally {
        if (mounted) {
          setState(() {
            _processingNotifications.remove(notificationId);
          });
        }
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (_userId != null && !_processingNotifications.contains(notificationId)) {
      setState(() {
        _processingNotifications.add(notificationId);
      });
      try {
        await context.read<NotificationViewModel>().deleteNotification(notificationId, _userId!);
      } finally {
        if (mounted) {
          setState(() {
            _processingNotifications.remove(notificationId);
          });
        }
      }
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

  Widget _buildNotificationItem(notification, bool isTablet, BuildContext context) {
    final isProcessing = _processingNotifications.contains(notification.id);
    final theme = Theme.of(context);
    
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.red.shade700],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_sweep,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 12 : 10,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: theme.dialogBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: isTablet ? 28 : 24),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Notification?',
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'This action cannot be undone. Are you sure you want to delete this notification?',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => _deleteNotification(notification.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
        child: Card(
          elevation: notification.isRead ? 2 : 6,
          color: isProcessing
              ? theme.primaryColor.withOpacity(0.1)
              : notification.isRead
                  ? theme.cardColor
                  : theme.primaryColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isProcessing
                  ? theme.primaryColor.withOpacity(0.3)
                  : notification.isRead
                      ? Colors.transparent
                      : theme.primaryColor.withOpacity(0.2),
              width: notification.isRead ? 0 : 2,
            ),
          ),
          child: Stack(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 28 : 24,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      backgroundImage: (notification.sender.profilePhoto != null &&
                              notification.sender.profilePhoto!.isNotEmpty)
                          ? NetworkImage(getFullImageUrl(notification.sender.profilePhoto))
                          : null,
                      child: (notification.sender.profilePhoto == null ||
                              notification.sender.profilePhoto!.isEmpty)
                          ? Icon(
                              Icons.person,
                              color: theme.primaryColor,
                              size: isTablet ? 28 : 24,
                            )
                          : null,
                    ),
                    if (!notification.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: isTablet ? 12 : 10,
                          height: isTablet ? 12 : 10,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  notification.message,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: isTablet ? 8 : 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isTablet ? 16 : 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              notification.sender.username,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification.type,
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: isTablet ? 14 : 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? theme.primaryColor.withOpacity(0.1)
                        : theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                    color: theme.primaryColor,
                    size: isTablet ? 20 : 18,
                  ),
                ),
                onTap: () {
                  if (!notification.isRead && !isProcessing) {
                    _markAsRead(notification.id);
                  }
                },
              ),
              if (isProcessing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Notifications',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.w600,
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: theme.appBarTheme.elevation,
            actions: [
              AnimatedBuilder(
                animation: _refreshAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _refreshAnimation.value * 2 * 3.14159,
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refresh,
                      tooltip: 'Refresh notifications',
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocConsumer<NotificationViewModel, NotificationState>(
            listener: (context, state) {
              if (state is NotificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is NotificationLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.primaryColor,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      Text(
                        'Loading notifications...',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is NotificationLoaded) {
                final notifications = state.notifications;
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none_outlined,
                            size: isTablet ? 80 : 64,
                            color: theme.primaryColor.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'When you receive notifications, they\'ll appear here',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: isTablet ? 16 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: theme.primaryColor,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification, isTablet, context);
                    },
                  ),
                );
              } else if (state is NotificationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: isTablet ? 80 : 64,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16,
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}