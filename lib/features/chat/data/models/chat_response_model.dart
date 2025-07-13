import 'package:equatable/equatable.dart';

class ChatResponseModel extends Equatable {
  final String response;
  final String sessionId;
  final DateTime timestamp;

  const ChatResponseModel({
    required this.response,
    required this.sessionId,
    required this.timestamp,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      response: json['response'] ?? '',
      sessionId: json['session_id'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [response, sessionId, timestamp];
}