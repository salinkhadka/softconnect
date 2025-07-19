import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';

import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_event.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_state.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';

import 'message_page.dart'; // Your MessagePage widget that uses MessageViewModel

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

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
    return FutureBuilder<String?>(
      future: getUserIdFromPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("User ID not found"));
        }
        final userId = snapshot.data!;

        // Trigger inbox load event once
        context
            .read<InboxViewModel>()
            .add(LoadInboxEvent(GetInboxParams(userId)));

        return BlocBuilder<InboxViewModel, InboxState>(
          builder: (context, state) {
            if (state is MessageLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MessageLoadedState) {
              if (state.inboxList.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }

              return ListView.builder(
                itemCount: state.inboxList.length,
                itemBuilder: (context, index) {
                  final item = state.inboxList[index];

                  String? imageUrl;
                  if (item.profilePhoto != null &&
                      item.profilePhoto!.isNotEmpty) {
                    const backendBaseUrl =
                        'http://10.0.2.2:2000'; // adjust as needed
                    imageUrl =
                        '$backendBaseUrl/${item.profilePhoto!.replaceAll('\\', '/')}';
                  }

                  return ListTile(
                    tileColor: item.lastMessageIsRead == false
                        ? Colors.blue.shade50
                        : null,
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
                                  return const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2));
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
                        fontWeight: item.lastMessageIsRead == false
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      item.lastMessage,
                      style: TextStyle(
                        fontWeight: item.lastMessageIsRead == false
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      timeAgo(item.lastMessageTime.toLocal()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: item.lastMessageIsRead == false
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      // Navigate to MessagePage with MessageViewModel provided
                      Navigator.push(
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
                    },
                  );
                },
              );
            } else if (state is MessageErrorState) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}
