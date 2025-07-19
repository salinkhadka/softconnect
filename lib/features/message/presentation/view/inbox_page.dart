import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_event.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_state.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  Future<String?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Helper: convert DateTime to "time ago" string
  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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

        // Load inbox when ready
        context
            .read<MessageViewModel>()
            .add(LoadInboxEvent(GetInboxParams(userId)));

        return BlocBuilder<MessageViewModel, MessageState>(
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

                  // Build image URL safely (adjust according to your backend & path)
                  String? imageUrl;
                  if (item.profilePhoto != null &&
                      item.profilePhoto!.isNotEmpty) {
                    // Adjust base URL as needed (see your FriendsPage logic)
                    const backendBaseUrl =
                        'http://10.0.2.2:2000'; // or make dynamic by platform
                    imageUrl =
                        '$backendBaseUrl/${item.profilePhoto!.replaceAll('\\', '/')}';
                  }

                  return ListTile(
                    tileColor: item.lastMessageIsRead == false
                        ? Colors.blue.shade50
                        : null, // light blue background if unread
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
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  );
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
