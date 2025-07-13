import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatSessionModel>> getAllSessions();
  Future<ChatSessionModel?> getSession(String sessionId);
  Future<void> saveSession(ChatSessionModel session);
  Future<void> deleteSession(String sessionId);
  Future<void> addMessageToSession(String sessionId, ChatMessageModel message);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _sessionsKey = 'chat_sessions';

  ChatLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ChatSessionModel>> getAllSessions() async {
    try {
      final sessionsJson = sharedPreferences.getString(_sessionsKey);
      if (sessionsJson == null) {
        return [];
      }
      
      final List<dynamic> sessionsList = json.decode(sessionsJson);
      return sessionsList
          .map((session) => ChatSessionModel.fromJson(session))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to load chat sessions');
    }
  }

  @override
  Future<ChatSessionModel?> getSession(String sessionId) async {
    final sessions = await getAllSessions();
    try {
      return sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSession(ChatSessionModel session) async {
    try {
      final sessions = await getAllSessions();
      final index = sessions.indexWhere((s) => s.id == session.id);
      
      if (index != -1) {
        sessions[index] = session;
      } else {
        sessions.add(session);
      }
      
      final sessionsJson = json.encode(
        sessions.map((s) => s.toJson()).toList(),
      );
      
      await sharedPreferences.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      throw CacheException(message: 'Failed to save chat session');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final sessions = await getAllSessions();
      sessions.removeWhere((session) => session.id == sessionId);
      
      final sessionsJson = json.encode(
        sessions.map((s) => s.toJson()).toList(),
      );
      
      await sharedPreferences.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      throw CacheException(message: 'Failed to delete chat session');
    }
  }

  @override
  Future<void> addMessageToSession(String sessionId, ChatMessageModel message) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) {
        throw CacheException(message: 'Session not found');
      }
      
      final updatedMessages = [...session.messages, message];
      final updatedSession = ChatSessionModel(
        id: session.id,
        messages: updatedMessages,
        createdAt: session.createdAt,
        lastMessageAt: message.timestamp,
      );
      
      await saveSession(updatedSession);
    } catch (e) {
      throw CacheException(message: 'Failed to add message to session');
    }
  }
}