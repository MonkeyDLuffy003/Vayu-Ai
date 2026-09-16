import '../models/saved_topic.dart';
import 'local_storage_service.dart';

class TopicService {
  final LocalStorageService _storage;

  TopicService(this._storage);

  // ============================================================
  // SAVE TOPIC
  // ============================================================

  Future<SavedTopic> saveTopic({
    required String title,
    required String content,
    List<String> tags = const [],
    bool pinned = false,
  }) async {
    final cleanTitle = title.trim();
    final cleanContent = content.trim();

    if (cleanTitle.isEmpty) {
      throw ArgumentError(
        'Topic title cannot be empty.',
      );
    }

    if (cleanContent.isEmpty) {
      throw ArgumentError(
        'Topic content cannot be empty.',
      );
    }

    final now = DateTime.now();

    final topic = SavedTopic(
      id: _generateId(),
      title: cleanTitle,
      content: cleanContent,
      createdAt: now,
      updatedAt: now,
      tags: _cleanTags(tags),
      pinned: pinned,
    );

    await _storage.saveTopic(topic);

    return topic;
  }

  // ============================================================
  // UPDATE TOPIC
  // ============================================================

  Future<void> updateTopic(
    SavedTopic topic, {
    String? title,
    String? content,
    List<String>? tags,
    bool? pinned,
  }) async {
    final updatedTopic = topic.copyWith(
      title: title?.trim(),
      content: content?.trim(),
      tags: tags != null
          ? _cleanTags(tags)
          : topic.tags,
      pinned: pinned,
      updatedAt: DateTime.now(),
    );

    await _storage.saveTopic(
      updatedTopic,
    );
  }

  // ============================================================
  // GET ALL TOPICS
  // ============================================================

  Future<List<SavedTopic>> getTopics() async {
    final topics =
        await _storage.getTopics();

    topics.sort(
      (a, b) {
        if (a.pinned != b.pinned) {
          return a.pinned ? -1 : 1;
        }

        return b.updatedAt.compareTo(
          a.updatedAt,
        );
      },
    );

    return topics;
  }

  // ============================================================
  // GET ONE TOPIC
  // ============================================================

  Future<SavedTopic?> getTopic(
    String topicId,
  ) async {
    final topics =
        await _storage.getTopics();

    try {
      return topics.firstWhere(
        (topic) => topic.id == topicId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // SEARCH TOPICS
  // ============================================================

  Future<List<SavedTopic>> searchTopics(
    String query,
  ) async {
    final cleanQuery =
        query.trim().toLowerCase();

    final topics =
        await getTopics();

    if (cleanQuery.isEmpty) {
      return topics;
    }

    return topics.where(
      (topic) {
        final title =
            topic.title.toLowerCase();

        final content =
            topic.content.toLowerCase();

        final tags = topic.tags
            .join(' ')
            .toLowerCase();

        return title.contains(
              cleanQuery,
            ) ||
            content.contains(
              cleanQuery,
            ) ||
            tags.contains(
              cleanQuery,
            );
      },
    ).toList();
  }

  // ============================================================
  // PIN / UNPIN TOPIC
  // ============================================================

  Future<void> setPinned(
    String topicId,
    bool pinned,
  ) async {
    final topic =
        await getTopic(topicId);

    if (topic == null) {
      return;
    }

    await updateTopic(
      topic,
      pinned: pinned,
    );
  }

  Future<void> togglePinned(
    String topicId,
  ) async {
    final topic =
        await getTopic(topicId);

    if (topic == null) {
      return;
    }

    await setPinned(
      topicId,
      !topic.pinned,
    );
  }

  // ============================================================
  // DELETE TOPIC
  // ============================================================

  Future<void> deleteTopic(
    String topicId,
  ) async {
    await _storage.deleteTopic(
      topicId,
    );
  }

  // ============================================================
  // DELETE ALL TOPICS
  // ============================================================

  Future<void> deleteAllTopics() async {
    final topics =
        await _storage.getTopics();

    for (final topic in topics) {
      await _storage.deleteTopic(
        topic.id,
      );
    }
  }

  // ============================================================
  // COMMAND HELPERS
  // ============================================================

  bool isSaveCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.startsWith(
          'save topic',
        ) ||
        command.startsWith(
          'remember this topic',
        ) ||
        command.startsWith(
          'save this',
        ) ||
        command.startsWith(
          'note this',
        );
  }

  bool isSearchCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.startsWith(
          'search topic',
        ) ||
        command.startsWith(
          'find topic',
        ) ||
        command.startsWith(
          'find my note',
        ) ||
        command.startsWith(
          'search my notes',
        );
  }

  bool isShowCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.contains(
          'show my topics',
        ) ||
        command.contains(
          'show my notes',
        ) ||
        command.contains(
          'list my topics',
        ) ||
        command.contains(
          'list my notes',
        );
  }

  bool isDeleteCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.startsWith(
          'delete topic',
        ) ||
        command.startsWith(
          'delete note',
        ) ||
        command.startsWith(
          'remove topic',
        );
  }

  // ============================================================
  // TAG CLEANUP
  // ============================================================

  List<String> _cleanTags(
    List<String> tags,
  ) {
    return tags
        .map(
          (tag) => tag.trim(),
        )
        .where(
          (tag) => tag.isNotEmpty,
        )
        .toSet()
        .toList();
  }

  // ============================================================
  // ID GENERATOR
  // ============================================================

  String _generateId() {
    return 'topic_${DateTime.now().microsecondsSinceEpoch}';
  }
}
