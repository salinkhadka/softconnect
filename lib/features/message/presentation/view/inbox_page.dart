import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/app/theme/theme_provider.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (userId == null) {
          return FutureBuilder<String?>(
            future: getUserIdFromPrefs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: Text(
                      "User ID not found",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              
              if (!_hasInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  userId = snapshot.data!;
                  context.read<InboxViewModel>().add(LoadInboxEvent(GetInboxParams(userId!)));
                  _hasInitialized = true;
                });
              }
              
              return _buildInboxContent(snapshot.data!, isTablet);
            },
          );
        }

        return _buildInboxContent(userId!, isTablet);
      },
    );
  }

  Widget _buildInboxContent(String currentUserId, bool isTablet) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocBuilder<InboxViewModel, InboxState>(
            builder: (context, state) {
              if (state is MessageLoadingState || state is MessageMarkingReadState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              } else if (state is MessageLoadedState || state is MessageMarkedReadState) {
                final inboxList = (state is MessageLoadedState)
                    ? state.inboxList
                    : (state is MessageMarkedReadState)
                        ? (context.read<InboxViewModel>().state is MessageLoadedState
                            ? (context.read<InboxViewModel>().state as MessageLoadedState).inboxList
                            : [])
                        : [];

                if (inboxList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: isTablet ? 80 : 64,
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          "No messages yet.",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: isTablet ? 20 : 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  onRefresh: _refreshInbox,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 8,
                    ),
                    itemCount: inboxList.length,
                    itemBuilder: (context, index) {
                      final item = inboxList[index];

                      String? imageUrl;
                      if (item.profilePhoto != null && item.profilePhoto!.isNotEmpty) {
                        const backendBaseUrl = ApiEndpoints.serverAddress;
                        imageUrl = '$backendBaseUrl/${item.profilePhoto!.replaceAll('\\', '/')}';
                      }

                      final bool shouldBold = item.lastMessageIsRead == false && item.lastMessageSenderId != currentUserId;

                      return Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                        decoration: BoxDecoration(
                          color: shouldBold 
                            ? Theme.of(context).primaryColor.withOpacity(0.1) 
                            : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: shouldBold 
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Theme.of(context).dividerColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 16,
                            vertical: isTablet ? 12 : 8,
                          ),
                          leading: (imageUrl != null)
                              ? CircleAvatar(
                                  radius: isTablet ? 28 : 22,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: ClipOval(
                                    child: Image.network(
                                      imageUrl,
                                      height: isTablet ? 56 : 44,
                                      width: isTablet ? 56 : 44,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: isTablet ? 32 : 24,
                                          color: Theme.of(context).primaryColor,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: isTablet ? 28 : 22,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: isTablet ? 32 : 24,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                          title: Text(
                            item.username,
                            style: TextStyle(
                              fontWeight: shouldBold ? FontWeight.bold : FontWeight.normal,
                              fontSize: isTablet ? 18 : 16,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                          subtitle: Text(
                            item.lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: shouldBold ? FontWeight.w500 : FontWeight.normal,
                              fontSize: isTablet ? 16 : 14,
                              color: shouldBold 
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timeAgo(item.lastMessageTime.toLocal()),
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: shouldBold ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (shouldBold) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () async {
                            context.read<InboxViewModel>().add(
                                  MarkMessagesReadEvent(MarkMessagesAsReadParams(item.id)),
                                );

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

                            _refreshInbox();
                          },
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
                        "Error: ${state.message}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isTablet ? 18 : 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        );
      },
    );
  }
}