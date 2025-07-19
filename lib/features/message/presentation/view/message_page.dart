import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _MessagePageState extends State<MessagePage> {
  String currentUserId = '';
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId') ?? '';
    setState(() {
      currentUserId = id;
    });
    if (id.isNotEmpty) {
      context.read<MessageViewModel>().add(
            LoadMessagesEvent(id, widget.otherUserId),
          );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<MessageViewModel>().add(
          SendMessageEvent(
            senderId: currentUserId,
            recipientId: widget.otherUserId,
            content: text,
          ),
        );

    _messageController.clear();
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<MessageViewModel>().add(DeleteMessageEvent(messageId: messageId));
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageViewModel, MessageState>(
      listener: (context, state) {
        if (state is MessageErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is MessageSentState || state is MessageDeletedState) {
          // Reload messages after sending or deleting one
          context.read<MessageViewModel>().add(
                LoadMessagesEvent(currentUserId, widget.otherUserId),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (widget.otherUserPhoto != null && widget.otherUserPhoto!.isNotEmpty)
                CircleAvatar(backgroundImage: NetworkImage(widget.otherUserPhoto!))
              else
                const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 8),
              Text(widget.otherUserName),
            ],
          ),
        ),
        body: currentUserId.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: BlocBuilder<MessageViewModel, MessageState>(
                      builder: (context, state) {
                        if (state is MessageLoadingState) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is MessageLoadedMessagesState) {
                          final messages = state.messages;

                          if (messages.isEmpty) {
                            return const Center(child: Text("No messages yet."));
                          }

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[messages.length - 1 - index];
                              final isMe = message.sender == currentUserId;

                              return GestureDetector(
                                onLongPress: () => _confirmDelete(message.id),
                                child: Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.content,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timeAgo(message.createdAt.toLocal()),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isMe ? Colors.white70 : Colors.black54,
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
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: "Type a message",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: Colors.blue,
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
