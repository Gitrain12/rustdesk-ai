enum MessageType {
  text,
  image,
  file,
  system,
}

enum ChatStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final ChatStatus status;
  final bool isMe;
  final String? filePath;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    this.type = MessageType.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.status = ChatStatus.sent,
    this.isMe = false,
    this.filePath,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: ChatStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChatStatus.sent,
      ),
      isMe: json['is_me'] ?? false,
      filePath: json['file_path'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'is_me': isMe,
      'file_path': filePath,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    ChatStatus? status,
    bool? isMe,
    String? filePath,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isMe: isMe ?? this.isMe,
      filePath: filePath ?? this.filePath,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatSession {
  final String id;
  final String peerId;
  final String peerName;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ChatSession({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.messages = const [],
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = false,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      peerId: json['peer_id'] ?? '',
      peerName: json['peer_name'] ?? 'Unknown',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e))
              .toList() ??
          [],
      lastMessageTime: DateTime.parse(
          json['last_message_time'] ?? DateTime.now().toIso8601String()),
      unreadCount: json['unread_count'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peer_id': peerId,
      'peer_name': peerName,
      'messages': messages.map((e) => e.toJson()).toList(),
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_active': isActive,
    };
  }

  ChatSession copyWith({
    String? id,
    String? peerId,
    String? peerName,
    List<ChatMessage>? messages,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
  }) {
    return ChatSession(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      messages: messages ?? this.messages,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }
}