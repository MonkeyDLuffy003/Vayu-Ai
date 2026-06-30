import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// All LLM calls go through your own backend (Cloud Functions), which
/// holds and rotates the actual provider API keys. The client only ever
/// authenticates with its own Firebase ID token.
class ApiService {
  ApiService({required this.baseUrl});

  final String baseUrl; // e.g. https://asia-south1-vayu-ai.cloudfunctions.net/api

  Future<String> _authHeader() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('not_authenticated');
    final token = await user.getIdToken();
    return 'Bearer $token';
  }

  Future<ChatResult> sendMessage({
    required String message,
    String? conversationId,
    String language = 'en',
  }) async {
    final auth = await _authHeader();
    final res = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json', 'Authorization': auth},
      body: jsonEncode({
        'message': message,
        'conversationId': conversationId,
        'language': language,
      }),
    );

    if (res.statusCode == 429) {
      throw RateLimitException(jsonDecode(res.body)['message'] ?? '');
    }
    if (res.statusCode != 200) {
      throw Exception('chat_failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    return ChatResult(
      conversationId: body['conversationId'],
      reply: body['reply'],
    );
  }

  Future<List<Map<String, dynamic>>> listConversations() async {
    final auth = await _authHeader();
    final res = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: {'Authorization': auth},
    );
    if (res.statusCode != 200) throw Exception('list_conversations_failed');
    return List<Map<String, dynamic>>.from(
        jsonDecode(res.body)['conversations']);
  }

  /// Returns the translated text (with a romanized line) for [text] in
  /// [targetLanguage]. Doesn't consume the daily chat quota.
  Future<String> translateText(String text, String targetLanguage) async {
    final auth = await _authHeader();
    final res = await http.post(
      Uri.parse('$baseUrl/translate'),
      headers: {'Content-Type': 'application/json', 'Authorization': auth},
      body: jsonEncode({'text': text, 'targetLanguage': targetLanguage}),
    );
    if (res.statusCode != 200) throw Exception('translate_failed');
    return jsonDecode(res.body)['translated'] as String;
  }

  /// Kicks off Stripe Checkout for the Pro tier; returns the hosted
  /// checkout URL to open in a browser/webview.
  Future<String> createProCheckoutSession() async {
    final auth = await _authHeader();
    final res = await http.post(
      Uri.parse('$baseUrl/billing/create-checkout-session'),
      headers: {'Content-Type': 'application/json', 'Authorization': auth},
    );
    if (res.statusCode != 200) throw Exception('checkout_session_failed');
    return jsonDecode(res.body)['url'] as String;
  }
}

class ChatResult {
  ChatResult({required this.conversationId, required this.reply});
  final String conversationId;
  final String reply;
}

class RateLimitException implements Exception {
  RateLimitException(this.message);
  final String message;
}
