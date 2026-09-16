import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/chat_message.dart';
import 'vayu_behaviour_service.dart';

class ChatService {
  final String baseUrl;

  ChatService({
    required this.baseUrl,
  });

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<ChatMessage> sendMessage({
    required String message,
    required String conversationId,
    String language = 'en',
    String? firebaseIdToken,
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw ChatServiceException(
        'Message cannot be empty.',
      );
    }

    if (trimmedMessage.length >
        VayuConstants.maxMessageLength) {
      throw ChatServiceException(
        'Message is too long.',
      );
    }

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (firebaseIdToken != null &&
          firebaseIdToken.isNotEmpty) {
        headers['Authorization'] =
            'Bearer $firebaseIdToken';
      }

      final uri = Uri.parse(
        '$baseUrl${VayuConstants.chatEndpoint}',
      );

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'message': trimmedMessage,
          'conversationId': conversationId,
          'language': language,
        }),
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return _parseAssistantMessage(
          response.body,
        );
      }

      if (response.statusCode == 429) {
        throw ChatServiceException(
          'rate_limit_reached',
        );
      }

      if (response.statusCode == 503) {
        throw ChatServiceException(
          'AI service temporarily unavailable.',
        );
      }

      throw ChatServiceException(
        'AI request failed '
        '(${response.statusCode}).',
      );
    } on ChatServiceException {
      rethrow;
    } catch (_) {
      throw ChatServiceException(
        VayuBehaviourService
            .connectionError(),
      );
    }
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  ChatMessage _parseAssistantMessage(
    String body,
  ) {
    try {
      final decoded =
          jsonDecode(body)
              as Map<String, dynamic>;

      final data =
          decoded['message'] ??
          decoded['data'] ??
          decoded;

      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson({
          ...data,
          'role':
              data['role'] ?? 'assistant',
        });
      }

      if (data is String) {
        return ChatMessage(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          role: MessageRole.assistant,
          content: data,
          language: 'en',
          timestamp: DateTime.now(),
        );
      }

      throw const FormatException(
        'Invalid AI response.',
      );
    } catch (_) {
      throw ChatServiceException(
        'Invalid response received from AI service.',
      );
    }
  }

  // ============================================================
  // HEALTH CHECK
  // ============================================================

  Future<bool> isBackendAvailable() async {
    try {
      final uri = Uri.parse(baseUrl);

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
          );

      return response.statusCode >= 200 &&
          response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}

// ============================================================
// EXCEPTION
// ============================================================

class ChatServiceException
    implements Exception {
  final String message;

  ChatServiceException(this.message);

  @override
  String toString() =>
      'ChatServiceException: $message';
}
