import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

/// Offline-first cache. Every successful chat update is mirrored here so
/// the app has something to show instantly on launch (or with no network)
/// before the live Firestore/API data arrives.
class LocalCacheService {
  static const _messagesBoxName = 'cached_messages';
  static const _conversationsBoxName = 'cached_conversations';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_messagesBoxName);
    await Hive.openBox(_conversationsBoxName);
  }

  Box get _messagesBox => Hive.box(_messagesBoxName);
  Box get _conversationsBox => Hive.box(_conversationsBoxName);

  /// Key is the conversationId, or 'draft' for an in-progress chat that
  /// hasn't been assigned a server-side conversation yet.
  Future<void> cacheMessages(String key, List<ChatMessage> messages) async {
    final serialized = messages
        .map((m) => {
              'role': m.role,
              'content': m.content,
              'translatedContent': m.translatedContent,
              'timestamp': m.timestamp.toIso8601String(),
            })
        .toList();
    await _messagesBox.put(key, serialized);
  }

  List<ChatMessage> getCachedMessages(String key) {
    final raw = _messagesBox.get(key);
    if (raw == null) return [];
    return (raw as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ChatMessage(
        role: map['role'] as String,
        content: map['content'] as String,
        translatedContent: map['translatedContent'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();
  }

  Future<void> cacheConversations(List<Map<String, dynamic>> conversations) {
    return _conversationsBox.put('list', conversations);
  }

  List<Map<String, dynamic>> getCachedConversations() {
    final raw = _conversationsBox.get('list');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<void> clearConversation(String key) => _messagesBox.delete(key);
}
