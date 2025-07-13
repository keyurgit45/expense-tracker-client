import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatSession extends Equatable {
  final String id;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  const ChatSession({
    required this.id,
    required this.messages,
    required this.createdAt,
    this.lastMessageAt,
  });

  ChatSession copyWith({
    String? id,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  @override
  List<Object?> get props => [id, messages, createdAt, lastMessageAt];
}