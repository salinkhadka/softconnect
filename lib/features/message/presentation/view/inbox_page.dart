import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';

import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_event.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_state.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';

import 'message_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with RouteAware {
  String? userId;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchInbox();
  }

  @override
  void didPopNext() {
    // This is called when returning from another page (like MessagePage)
    super.didPopNext();
    _refreshInbox();
  }

  Future<void> _loadUserIdAndFetchInbox() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    
    if (userId != null && !_hasInitialized) {
      context.read<InboxViewModel>().add(LoadInboxEvent(GetInboxParams(userId!)));
      _hasInitialized = true;
    }
  }

  Future<void> _refreshInbox() async {
    if (userId != null) {
      context.read<InboxViewModel>().add(LoadInboxEvent(GetInboxParams(userId!)));
    }
  }

  Future<String?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
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
    if (userId == null) {
      return FutureBuilder<String?>(
        future: getUserIdFromPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User ID not found"));
          }
          
          // Store userId and trigger initial load
          if (!_hasInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userId = snapshot.data!;
              context.read<InboxViewModel>().add(LoadInboxEvent(GetInboxParams(userId!)));
              _hasInitialized = true;
            });
          }
          
          return _buildInboxContent(snapshot.data!);
        },
      );
    }

    return _buildInboxContent(userId!);
  }

  Widget _buildInboxContent(String currentUserId) {
    return BlocBuilder<InboxViewModel, InboxState>(
      builder: (context, state) {
        if (state is MessageLoadingState || state is MessageMarkingReadState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MessageLoadedState || state is MessageMarkedReadState) {
          final inboxList = (state is MessageLoadedState)
              ? state.inboxList
              : (state is MessageMarkedReadState)
                  ? (context.read<InboxViewModel>().state is MessageLoadedState
                      ? (context.read<InboxViewModel>().state as MessageLoadedState).inboxList
                      : [])
                  : [];

          if (inboxList.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          return RefreshIndicator(
            onRefresh: _refreshInbox,
            child: ListView.builder(
              itemCount: inboxList.length,
              itemBuilder: (context, index) {
                final item = inboxList[index];

                String? imageUrl;
                if (item.profilePhoto != null && item.profilePhoto!.isNotEmpty) {
                  const backendBaseUrl = 'http://10.0.2.2:2000';
                  imageUrl = '$backendBaseUrl/${item.profilePhoto!.replaceAll('\\', '/')}';
                }

                final bool shouldBold = item.lastMessageIsRead == false && item.lastMessageSenderId != currentUserId;

                return ListTile(
                  tileColor: shouldBold ? Colors.blue.shade50 : null,
                  leading: (imageUrl != null)
                      ? CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.network(
                              imageUrl,
                              height: 44,
                              width: 44,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 32);
                              },
                            ),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 22,
                          child: Icon(Icons.person),
                        ),
                  title: Text(
                    item.username,
                    style: TextStyle(
                      fontWeight: shouldBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    item.lastMessage,
                    style: TextStyle(
                      fontWeight: shouldBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    timeAgo(item.lastMessageTime.toLocal()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: shouldBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () async {
                    // Mark messages as read for this conversation
                    context.read<InboxViewModel>().add(
                          MarkMessagesReadEvent(MarkMessagesAsReadParams(item.id)),
                        );

                    // Navigate to MessagePage and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<MessageViewModel>(
                          create: (_) => serviceLocator<MessageViewModel>(),
                          child: MessagePage(
                            otherUserId: item.id,
                            otherUserName: item.username,
                            otherUserPhoto: imageUrl,
                          ),
                        ),
                      ),
                    );

                    // Refresh inbox when returning from MessagePage
                    _refreshInbox();
                  },
                );
              },
            ),
          );
        } else if (state is MessageErrorState) {
          return Center(child: Text("Error: ${state.message}"));
        }
        return const SizedBox();
      },
    );
  }
}