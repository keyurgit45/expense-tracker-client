import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/usecases/create_chat_session.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessage sendMessage;
  final CreateChatSession createChatSession;
  final ChatRepository chatRepository;

  ChatCubit({
    required this.sendMessage,
    required this.createChatSession,
    required this.chatRepository,
  }) : super(ChatInitial());

  ChatSession? _currentSession;

  Future<void> startNewChat() async {
    emit(ChatLoading());

    final result = await createChatSession(NoParams());

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (session) {
        _currentSession = session;
        emit(ChatLoaded(session: session));
      },
    );
  }

  Future<void> loadSession(String sessionId) async {
    emit(ChatLoading());

    final result = await chatRepository.getSession(sessionId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (session) {
        _currentSession = session;
        emit(ChatLoaded(session: session));
      },
    );
  }

  Future<void> sendChatMessage(String message) async {
    if (_currentSession == null) {
      emit(const ChatError(message: 'No active chat session'));
      return;
    }

    final currentState = state;
    if (currentState is ChatLoaded) {
      // Show sending state
      emit(currentState.copyWith(isSending: true));

      // Add user message to the session immediately for better UX
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: _currentSession!.id,
      );

      final updatedMessages = [..._currentSession!.messages, userMessage];
      _currentSession = _currentSession!.copyWith(
        messages: updatedMessages,
        lastMessageAt: userMessage.timestamp,
      );
      
      emit(ChatLoaded(session: _currentSession!, isSending: true));

      // Send message to server
      final result = await sendMessage(
        SendMessageParams(
          message: message,
          sessionId: _currentSession!.id,
        ),
      );

      result.fold(
        (failure) {
          // Remove the user message on failure
          final messages = List<ChatMessage>.from(_currentSession!.messages);
          if (messages.isNotEmpty) {
            messages.removeLast();
          }
          _currentSession = _currentSession!.copyWith(messages: messages);
          emit(ChatError(
            message: failure.message,
            lastSession: _currentSession,
          ));
        },
        (assistantMessage) {
          // Add assistant message
          final allMessages = [..._currentSession!.messages, assistantMessage];
          _currentSession = _currentSession!.copyWith(
            messages: allMessages,
            lastMessageAt: assistantMessage.timestamp,
          );
          emit(ChatLoaded(session: _currentSession!));
        },
      );
    }
  }

  Future<void> loadAllSessions() async {
    emit(ChatLoading());

    final result = await chatRepository.getAllSessions();

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (sessions) => emit(ChatSessionsLoaded(sessions: sessions)),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final result = await chatRepository.deleteSession(sessionId);

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => loadAllSessions(),
    );
  }
}