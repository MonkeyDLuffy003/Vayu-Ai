enum MessageRole {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final String language;
  final DateTime timestamp;
  final String? model;
  final int? tokensUsed;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.language,
    required this.timestamp,
    this.model,
    this.tokensUsed,
  });

  // ============================================================
  // COPY
  // ============================================================

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    String? language,
    DateTime? timestamp,
    String? model,
    int? tokensUsed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      model: model ?? this.model,
      tokensUsed: tokensUsed ?? this.tokensUsed,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
      'model': model,
      'tokensUsed': tokensUsed,
    };
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      role: _roleFromString(
        json['role'] as String?,
      ),
      content:
          json['content'] as String? ?? '',
      language:
          json['language'] as String? ?? 'en',
      timestamp:
          DateTime.tryParse(
                json['timestamp']
                    as String? ??
                    '',
              ) ??
              DateTime.now(),
      model: json['model'] as String?,
      tokensUsed:
          json['tokensUsed'] as int?,
    );
  }

  // ============================================================
  // ROLE CONVERSION
  // ============================================================

  static MessageRole _roleFromString(
    String? value,
  ) {
    switch (value) {
      case 'user':
        return MessageRole.user;

      case 'assistant':
        return MessageRole.assistant;

      case 'system':
        return MessageRole.system;

      default:
        return MessageRole.user;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isUser =>
      role == MessageRole.user;

  bool get isAssistant =>
      role == MessageRole.assistant;

  bool get isSystem =>
      role == MessageRole.system;
}
