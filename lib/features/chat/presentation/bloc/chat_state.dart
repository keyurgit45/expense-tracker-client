import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_session.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatSession session;
  final bool isSending;

  const ChatLoaded({
    required this.session,
    this.isSending = false,
  });

  @override
  List<Object?> get props => [session, isSending];

  ChatLoaded copyWith({
    ChatSession? session,
    bool? isSending,
  }) {
    return ChatLoaded(
      session: session ?? this.session,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  final ChatSession? lastSession;

  const ChatError({
    required this.message,
    this.lastSession,
  });

  @override
  List<Object?> get props => [message, lastSession];
}

class ChatSessionsLoaded extends ChatState {
  final List<ChatSession> sessions;

  const ChatSessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}