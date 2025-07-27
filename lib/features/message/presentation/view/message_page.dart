import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_event.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_state.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';
import 'package:softconnect/features/profile/presentation/view/user_profile.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';

class MessagePage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  const MessagePage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with WidgetsBindingObserver {
  String currentUserId = '';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _refreshTimer;
  bool _isTyping = false;
  bool _isAppInForeground = true;

  void navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<UserProfileViewModel>(
              create: (_) => serviceLocator<UserProfileViewModel>(),
            ),
            BlocProvider<FeedViewModel>(
              create: (_) => serviceLocator<FeedViewModel>(),
            ),
            BlocProvider<CommentViewModel>(
              create: (_) => serviceLocator<CommentViewModel>(),
            ),
          ],
          child: UserProfilePage(userId: userId),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUserId();
    _setupMessageController();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isAppInForeground = state == AppLifecycleState.resumed;
    
    if (_isAppInForeground && currentUserId.isNotEmpty) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
  }

  void _setupMessageController() {
    _messageController.addListener(() {
      final isCurrentlyTyping = _messageController.text.trim().isNotEmpty;
      if (isCurrentlyTyping != _isTyping) {
        setState(() {
          _isTyping = isCurrentlyTyping;
        });
      }
    });
  }

  void _startAutoRefresh() {
    _stopAutoRefresh(); // Cancel any existing timer
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isAppInForeground && currentUserId.isNotEmpty && mounted) {
        context.read<MessageViewModel>().add(
          LoadMessagesEvent(currentUserId, widget.otherUserId),
        );
      }
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('userId') ?? '';
      if (mounted) {
        setState(() {
          currentUserId = id;
        });
        if (id.isNotEmpty) {
          context.read<MessageViewModel>().add(
            LoadMessagesEvent(id, widget.otherUserId),
          );
          _startAutoRefresh();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId.isEmpty) return;

    context.read<MessageViewModel>().add(
      SendMessageEvent(
        senderId: currentUserId,
        recipientId: widget.otherUserId,
        content: text,
      ),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text(
          "Delete Message",
          style: TextStyle(
            color: Theme.of(context).dialogTheme.titleTextStyle?.color,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this message?",
          style: TextStyle(
            color: Theme.of(context).dialogTheme.contentTextStyle?.color,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              context.read<MessageViewModel>().add(
                DeleteMessageEvent(messageId: messageId),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildMessageInput(bool isTablet) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isTyping 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: isTablet ? 24 : 20,
                  ),
                  onPressed: _isTyping ? _sendMessage : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return BlocListener<MessageViewModel, MessageState>(
          listener: (context, state) {
            if (state is MessageErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is MessageSentState || state is MessageDeletedState) {
              context.read<MessageViewModel>().add(
                LoadMessagesEvent(currentUserId, widget.otherUserId),
              );
              _scrollToBottom();
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              elevation: Theme.of(context).appBarTheme.elevation,
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => navigateToUserProfile(context, widget.otherUserId),
                    child: widget.otherUserPhoto != null && widget.otherUserPhoto!.isNotEmpty
                        ? CircleAvatar(
                            radius: isTablet ? 20 : 16,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            backgroundImage: NetworkImage(widget.otherUserPhoto!),
                          )
                        : CircleAvatar(
                            radius: isTablet ? 20 : 16,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => navigateToUserProfile(context, widget.otherUserId),
                      child: Text(
                        widget.otherUserName,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: currentUserId.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: BlocBuilder<MessageViewModel, MessageState>(
                          builder: (context, state) {
                            if (state is MessageLoadingState) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            } else if (state is MessageLoadedMessagesState) {
                              final messages = state.messages;

                              if (messages.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: isTablet ? 80 : 64,
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                      ),
                                      SizedBox(height: isTablet ? 24 : 16),
                                      Text(
                                        "No messages yet.",
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.titleMedium?.color,
                                          fontSize: isTablet ? 18 : 16,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 12 : 8),
                                      Text(
                                        "Send a message to start the conversation!",
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                          fontSize: isTablet ? 14 : 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[messages.length - 1 - index];
                                    final isMe = message.sender == currentUserId;

                                    return GestureDetector(
                                      onLongPress: isMe ? () => _confirmDelete(message.id) : null,
                                      child: Align(
                                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: isTablet ? 6 : 4,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: isTablet ? 12 : 10,
                                            horizontal: isTablet ? 16 : 14,
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * (isTablet ? 0.6 : 0.7),
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMe 
                                              ? Theme.of(context).primaryColor 
                                              : Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(isTablet ? 16 : 12),
                                              topRight: Radius.circular(isTablet ? 16 : 12),
                                              bottomLeft: Radius.circular(isMe ? (isTablet ? 16 : 12) : (isTablet ? 4 : 2)),
                                              bottomRight: Radius.circular(isMe ? (isTablet ? 4 : 2) : (isTablet ? 16 : 12)),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.content,
                                                style: TextStyle(
                                                  color: isMe 
                                                    ? Theme.of(context).colorScheme.onPrimary
                                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                                  fontSize: isTablet ? 16 : 14,
                                                ),
                                              ),
                                              SizedBox(height: isTablet ? 6 : 4),
                                              Text(
                                                timeAgo(message.createdAt.toLocal()),
                                                style: TextStyle(
                                                  fontSize: isTablet ? 12 : 10,
                                                  color: isMe 
                                                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7) 
                                                      : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (state is MessageErrorState) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: isTablet ? 80 : 64,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: isTablet ? 24 : 16),
                                    Text(
                                      'Error: ${state.message}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: isTablet ? 18 : 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: isTablet ? 16 : 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<MessageViewModel>().add(
                                          LoadMessagesEvent(currentUserId, widget.otherUserId),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      SafeArea(
                        child: _buildMessageInput(isTablet),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}