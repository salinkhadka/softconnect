class MessageInboxEntity {
  final String id; // other user ID
  final String username;
  final String email;
  final String? profilePhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool lastMessageIsRead;
  final String lastMessageSenderId;

  MessageInboxEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageIsRead,
    required this.lastMessageSenderId,
  });
}
