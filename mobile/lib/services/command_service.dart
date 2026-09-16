class VayuCommand {
  final VayuCommandType type;
  final String originalText;
  final String? argument;

  const VayuCommand({
    required this.type,
    required this.originalText,
    this.argument,
  });
}

enum VayuCommandType {
  chat,

  // Memory
  saveMemory,
  findMemory,
  deleteMemory,
  clearMemory,

  // Topics / notes
  saveTopic,
  showTopics,
  searchTopic,
  deleteTopic,

  // Alarms
  setAlarm,
  showAlarms,
  cancelAlarm,

  // Navigation / app
  openSettings,
  openTopics,
  openChat,
  openHome,

  // Voice
  stopSpeaking,

  // Local data
  clearLocalData,
}

class CommandService {
  // ============================================================
  // PARSE COMMAND
  // ============================================================

  VayuCommand parse(
    String text,
  ) {
    final cleanText =
        text.trim();

    if (cleanText.isEmpty) {
      return VayuCommand(
        type: VayuCommandType.chat,
        originalText: cleanText,
      );
    }

    final command =
        cleanText.toLowerCase();

    // ============================================================
    // MEMORY COMMANDS
    // ============================================================

    if (_startsWithAny(
      command,
      [
        'remember ',
        'remember that ',
        'save memory ',
        'remember this ',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.saveMemory,
        originalText: cleanText,
        argument: _removePrefix(
          cleanText,
          [
            'remember ',
            'remember that ',
            'save memory ',
            'remember this ',
          ],
        ),
      );
    }

    if (_containsAny(
      command,
      [
        'what do you remember',
        'what did you remember',
        'show my memories',
        'show memories',
        'search memory',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.findMemory,
        originalText: cleanText,
      );
    }

    if (_startsWithAny(
      command,
      [
        'forget ',
        'delete memory ',
        'remove memory ',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.deleteMemory,
        originalText: cleanText,
        argument: _removePrefix(
          cleanText,
          [
            'forget ',
            'delete memory ',
            'remove memory ',
          ],
        ),
      );
    }

    if (_containsAny(
      command,
      [
        'forget everything',
        'clear memories',
        'clear all memories',
        'delete all memories',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.clearMemory,
        originalText: cleanText,
      );
    }

    // ============================================================
    // TOPIC / NOTE COMMANDS
    // ============================================================

    if (_startsWithAny(
      command,
      [
        'save topic ',
        'save this topic ',
        'save note ',
        'save this note ',
        'note this ',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.saveTopic,
        originalText: cleanText,
        argument: _removePrefix(
          cleanText,
          [
            'save topic ',
            'save this topic ',
            'save note ',
            'save this note ',
            'note this ',
          ],
        ),
      );
    }

    if (_containsAny(
      command,
      [
        'show my topics',
        'show my notes',
        'list my topics',
        'list my notes',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.showTopics,
        originalText: cleanText,
      );
    }

    if (_startsWithAny(
      command,
      [
        'search topic ',
        'find topic ',
        'search note ',
        'find note ',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.searchTopic,
        originalText: cleanText,
        argument: _removePrefix(
          cleanText,
          [
            'search topic ',
            'find topic ',
            'search note ',
            'find note ',
          ],
        ),
      );
    }

    if (_startsWithAny(
      command,
      [
        'delete topic ',
        'delete note ',
        'remove topic ',
        'remove note ',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.deleteTopic,
        originalText: cleanText,
        argument: _removePrefix(
          cleanText,
          [
            'delete topic ',
            'delete note ',
            'remove topic ',
            'remove note ',
          ],
        ),
      );
    }

    // ============================================================
    // ALARM COMMANDS
    // ============================================================

    if (_containsAny(
      command,
      [
        'set an alarm',
        'set alarm',
        'wake me',
        'alarm for',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.setAlarm,
        originalText: cleanText,
      );
    }

    if (_containsAny(
      command,
      [
        'show alarms',
        'show my alarms',
        'list alarms',
        'next alarm',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.showAlarms,
        originalText: cleanText,
      );
    }

    if (_containsAny(
      command,
      [
        'cancel alarm',
        'cancel my alarm',
        'delete alarm',
        'remove alarm',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.cancelAlarm,
        originalText: cleanText,
      );
    }

    // ============================================================
    // APP NAVIGATION
    // ============================================================

    if (_containsAny(
      command,
      [
        'open settings',
        'show settings',
        'go to settings',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.openSettings,
        originalText: cleanText,
      );
    }

    if (_containsAny(
      command,
      [
        'open topics',
        'show topics',
        'go to topics',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.openTopics,
        originalText: cleanText,
      );
    }

    if (_containsAny(
      command,
      [
        'open chat',
        'go to chat',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.openChat,
        originalText: cleanText,
      );
    }

    if (_containsAny(
      command,
      [
        'go home',
        'open home',
        'go to home',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.openHome,
        originalText: cleanText,
      );
    }

    // ============================================================
    // VOICE
    // ============================================================

    if (_containsAny(
      command,
      [
        'stop speaking',
        'stop talking',
        'be quiet',
        'silence',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.stopSpeaking,
        originalText: cleanText,
      );
    }

    // ============================================================
    // LOCAL DATA
    // ============================================================

    if (_containsAny(
      command,
      [
        'clear all local data',
        'clear all vayu data',
        'factory reset vayu',
      ],
    )) {
      return VayuCommand(
        type: VayuCommandType.clearLocalData,
        originalText: cleanText,
      );
    }

    // ============================================================
    // DEFAULT CHAT
    // ============================================================

    return VayuCommand(
      type: VayuCommandType.chat,
      originalText: cleanText,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _startsWithAny(
    String text,
    List<String> prefixes,
  ) {
    return prefixes.any(
      (prefix) => text.startsWith(prefix),
    );
  }

  bool _containsAny(
    String text,
    List<String> phrases,
  ) {
    return phrases.any(
      (phrase) => text.contains(phrase),
    );
  }

  String? _removePrefix(
    String original,
    List<String> prefixes,
  ) {
    final lower =
        original.toLowerCase();

    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        return original
            .substring(prefix.length)
            .trim();
      }
    }

    return null;
  }
}
