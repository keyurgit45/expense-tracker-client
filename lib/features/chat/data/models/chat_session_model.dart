import '../../domain/entities/chat_session.dart';
import 'chat_message_model.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required super.id,
    required super.messages,
    required super.createdAt,
    super.lastMessageAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((message) => ChatMessageModel.fromJson(message))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
    );
  }

  factory ChatSessionModel.fromEntity(ChatSession entity) {
    return ChatSessionModel(
      id: entity.id,
      messages: entity.messages,
      createdAt: entity.createdAt,
      lastMessageAt: entity.lastMessageAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages
          .map((message) => ChatMessageModel.fromEntity(message).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }
}