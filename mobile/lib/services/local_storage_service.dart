import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/saved_topic.dart';

class LocalStorageService {
  final SharedPreferences preferences;

  LocalStorageService(this.preferences);

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _conversationsKey =
      'vayu_conversations';

  static const String _messagesPrefix =
      'vayu_messages_';

  static const String _topicsKey =
      'vayu_saved_topics';

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  Future<void> saveConversation(
    Conversation conversation,
  ) async {
    final conversations =
        await getConversations();

    final index = conversations.indexWhere(
      (item) => item.id == conversation.id,
    );

    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }

    await _saveConversations(
      conversations,
    );
  }

  Future<List<Conversation>>
      getConversations() async {
    final raw =
        preferences.getString(
      _conversationsKey,
    );

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw) as List;

      return decoded
          .map(
            (item) =>
                Conversation.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteConversation(
    String conversationId,
  ) async {
    final conversations =
        await getConversations();

    conversations.removeWhere(
      (item) =>
          item.id == conversationId,
    );

    await _saveConversations(
      conversations,
    );

    await deleteMessages(
      conversationId,
    );
  }

  Future<void> _saveConversations(
    List<Conversation> conversations,
  ) async {
    final encoded = jsonEncode(
      conversations
          .map(
            (conversation) =>
                conversation.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _conversationsKey,
      encoded,
    );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  Future<void> saveMessages(
    String conversationId,
    List<ChatMessage> messages,
  ) async {
    final encoded = jsonEncode(
      messages
          .map(
            (message) => message.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      '$_messagesPrefix$conversationId',
      encoded,
    );
  }

  Future<List<ChatMessage>> getMessages(
    String conversationId,
  ) async {
    final raw =
        preferences.getString(
      '$_messagesPrefix$conversationId',
    );

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw) as List;

      return decoded
          .map(
            (item) =>
                ChatMessage.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addMessage(
    String conversationId,
    ChatMessage message,
  ) async {
    final messages =
        await getMessages(
      conversationId,
    );

    messages.add(message);

    await saveMessages(
      conversationId,
      messages,
    );
  }

  Future<void> deleteMessages(
    String conversationId,
  ) async {
    await preferences.remove(
      '$_messagesPrefix$conversationId',
    );
  }

  // ============================================================
  // SAVED TOPICS
  // ============================================================

  Future<void> saveTopic(
    SavedTopic topic,
  ) async {
    final topics =
        await getTopics();

    final index = topics.indexWhere(
      (item) => item.id == topic.id,
    );

    if (index >= 0) {
      topics[index] = topic;
    } else {
      topics.add(topic);
    }

    await _saveTopics(topics);
  }

  Future<List<SavedTopic>> getTopics() async {
    final raw =
        preferences.getString(
      _topicsKey,
    );

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw) as List;

      return decoded
          .map(
            (item) =>
                SavedTopic.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteTopic(
    String topicId,
  ) async {
    final topics =
        await getTopics();

    topics.removeWhere(
      (item) => item.id == topicId,
    );

    await _saveTopics(topics);
  }

  Future<void> _saveTopics(
    List<SavedTopic> topics,
  ) async {
    final encoded = jsonEncode(
      topics
          .map(
            (topic) => topic.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _topicsKey,
      encoded,
    );
  }

  // ============================================================
  // CLEAR LOCAL DATA
  // ============================================================

  Future<void> clearAllLocalData() async {
    final keys =
        preferences.getKeys();

    for (final key in keys) {
      if (key.startsWith(
            'vayu_',
          )) {
        await preferences.remove(key);
      }
    }
  }
}
