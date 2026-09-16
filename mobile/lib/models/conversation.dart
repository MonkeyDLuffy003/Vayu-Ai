class Conversation {
  final String id;
  final String userId;
  final String title;
  final String language;
  final String model;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.language,
    required this.model,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================================
  // COPY
  // ============================================================

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    String? language,
    String? model,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      language: language ?? this.language,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'language': language,
      'model': model,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json,
  ) {
    return Conversation(
      id: json['id'] as String? ?? '',
      userId:
          json['userId'] as String? ?? '',
      title:
          json['title'] as String? ??
              'New Conversation',
      language:
          json['language'] as String? ??
              'en',
      model:
          json['model'] as String? ??
              'gemini-2.5-flash',
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
    );
  }
}
