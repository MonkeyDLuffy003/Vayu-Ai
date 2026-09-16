import '../models/chat_message.dart';

class VayuBehaviourService {
  VayuBehaviourService._();

  static const String assistantName = 'Vayu';
  static const String developerTitle = 'Sir';

  // ============================================================
  // WELCOME
  // ============================================================

  static String welcome() {
    return 'Welcome home, Sir. Systems are online. '
        'What are we building tonight?';
  }

  // ============================================================
  // RESPONSE FRAMING
  // ============================================================

  static String frameResponse({
    required String response,
    ChatMessage? previousMessage,
  }) {
    final cleaned = response.trim();

    if (cleaned.isEmpty) {
      return 'I’m here, Sir. What should we work on?';
    }

    return cleaned;
  }

  // ============================================================
  // ERROR RESPONSES
  // ============================================================

  static String connectionError() {
    return 'I can’t reach the AI service right now, Sir. '
        'The local system is still available.';
  }

  static String genericError() {
    return 'Something went wrong, Sir. '
        'Let’s check the system and try again.';
  }

  // ============================================================
  // OFFLINE RESPONSE
  // ============================================================

  static String offlineResponse() {
    return 'Network connection is unavailable, Sir. '
        'I can still work with your saved local data.';
  }

  // ============================================================
  // COMMAND DETECTION
  // ============================================================

  static bool isSaveTopicCommand(
    String input,
  ) {
    final text = input.trim().toLowerCase();

    return text.startsWith(
          'save topic',
        ) ||
        text.startsWith(
          'save this topic',
        ) ||
        text.startsWith(
          'remember this',
        ) ||
        text.startsWith(
          'save this',
        );
  }

  static bool isShowTopicsCommand(
    String input,
  ) {
    final text = input.trim().toLowerCase();

    return text == 'show my topics' ||
        text == 'show saved topics' ||
        text == 'my topics' ||
        text == 'saved topics';
  }

  static bool isDeleteTopicCommand(
    String input,
  ) {
    final text = input.trim().toLowerCase();

    return text.startsWith(
      'delete topic',
    );
  }

  // ============================================================
  // TOPIC EXTRACTION
  // ============================================================

  static String extractTopicContent(
    String input,
  ) {
    final text = input.trim();

    final prefixes = [
      'save this topic:',
      'save topic:',
      'remember this:',
      'save this:',
    ];

    for (final prefix in prefixes) {
      if (text.toLowerCase().startsWith(prefix)) {
        return text
            .substring(prefix.length)
            .trim();
      }
    }

    return text;
  }

  // ============================================================
  // STATUS FRAMING
  // ============================================================

  static String thinkingMessage() {
    return 'Give me a moment, Sir. I’m working on it.';
  }

  static String listeningMessage() {
    return 'I’m listening, Sir.';
  }

  static String speakingMessage() {
    return 'Here’s what I found, Sir.';
  }

  static String taskCompleteMessage() {
    return 'Done, Sir. The task is complete.';
  }

  static String taskFailedMessage() {
    return 'I couldn’t complete that task, Sir. '
        'Let’s troubleshoot it.';
  }

  // ============================================================
  // CONTEXTUAL FRAMING
  // ============================================================

  static String frameTaskStart(
    String task,
  ) {
    final cleaned = task.trim();

    if (cleaned.isEmpty) {
      return thinkingMessage();
    }

    return 'Working on $cleaned, Sir.';
  }

  // ============================================================
  // SAFETY / CONFIRMATION
  // ============================================================

  static bool requiresConfirmation(
    String action,
  ) {
    final text = action.toLowerCase();

    const sensitiveActions = [
      'delete all',
      'clear all',
      'remove account',
      'send message',
      'make payment',
      'purchase',
      'factory reset',
    ];

    return sensitiveActions.any(
      text.contains,
    );
  }

  static String confirmationMessage(
    String action,
  ) {
    return 'This action can make a significant change, Sir. '
        'Please confirm before I continue: $action';
  }
}
