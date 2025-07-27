import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_event.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_state.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';

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
        backgroundColor: Themecolor.white,
        title: Text(
          "Delete Message",
          style: TextStyle(color: Themecolor.purple),
        ),
        content: Text(
          "Are you sure you want to delete this message?",
          style: TextStyle(color: Themecolor.purple),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Themecolor.lavender),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: Themecolor.white,
        border: Border(
          top: BorderSide(
            color: Themecolor.lavender.withOpacity(0.3),
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
                color: Themecolor.purple,
              ),
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: Themecolor.lavender,
                  fontSize: isTablet ? 16 : 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                  borderSide: BorderSide(color: Themecolor.lavender),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                  borderSide: BorderSide(color: Themecolor.purple, width: 2),
                ),
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
              color: _isTyping ? Themecolor.purple : Themecolor.lavender,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Themecolor.white,
                size: isTablet ? 24 : 20,
              ),
              onPressed: _isTyping ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
        backgroundColor: Themecolor.white,
        appBar: AppBar(
          backgroundColor: Themecolor.purple,
          foregroundColor: Themecolor.white,
          title: Row(
            children: [
              if (widget.otherUserPhoto != null && widget.otherUserPhoto!.isNotEmpty)
                CircleAvatar(
                  radius: isTablet ? 20 : 16,
                  backgroundColor: Themecolor.lavender,
                  backgroundImage: NetworkImage(widget.otherUserPhoto!),
                )
              else
                CircleAvatar(
                  radius: isTablet ? 20 : 16,
                  backgroundColor: Themecolor.lavender,
                  child: Icon(
                    Icons.person,
                    color: Themecolor.purple,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  widget.otherUserName,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: currentUserId.isEmpty
            ? Center(
                child: CircularProgressIndicator(color: Themecolor.purple),
              )
            : Column(
                children: [
                  Expanded(
                    child: BlocBuilder<MessageViewModel, MessageState>(
                      builder: (context, state) {
                        if (state is MessageLoadingState) {
                          return Center(
                            child: CircularProgressIndicator(color: Themecolor.purple),
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
                                    color: Themecolor.lavender,
                                  ),
                                  SizedBox(height: isTablet ? 24 : 16),
                                  Text(
                                    "No messages yet.",
                                    style: TextStyle(
                                      color: Themecolor.purple,
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 12 : 8),
                                  Text(
                                    "Send a message to start the conversation!",
                                    style: TextStyle(
                                      color: Themecolor.lavender,
                                      fontSize: isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
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
                                      color: isMe ? Themecolor.purple : Themecolor.lavender.withOpacity(0.3),
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
                                            color: isMe ? Themecolor.white : Themecolor.purple,
                                            fontSize: isTablet ? 16 : 14,
                                          ),
                                        ),
                                        SizedBox(height: isTablet ? 6 : 4),
                                        Text(
                                          timeAgo(message.createdAt.toLocal()),
                                          style: TextStyle(
                                            fontSize: isTablet ? 12 : 10,
                                            color: isMe 
                                                ? Themecolor.white.withOpacity(0.7) 
                                                : Themecolor.purple.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
                                    backgroundColor: Themecolor.purple,
                                    foregroundColor: Themecolor.white,
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
  }
}