class SavedTopic {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool pinned;

  const SavedTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.pinned = false,
  });

  // ============================================================
  // COPY
  // ============================================================

  SavedTopic copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? pinned,
  }) {
    return SavedTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'pinned': pinned,
    };
  }

  factory SavedTopic.fromJson(
    Map<String, dynamic> json,
  ) {
    return SavedTopic(
      id: json['id'] as String? ?? '',
      title:
          json['title'] as String? ??
              'Untitled Topic',
      content:
          json['content'] as String? ?? '',
      createdAt:
          DateTime.tryParse(
                json['createdAt']
                    as String? ??
                    '',
              ) ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(
                json['updatedAt']
                    as String? ??
                    '',
              ) ??
              DateTime.now(),
      tags: List<String>.from(
        json['tags'] ?? const [],
      ),
      pinned:
          json['pinned'] as bool? ?? false,
    );
  }
}
