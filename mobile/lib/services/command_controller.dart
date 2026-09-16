import 'command_service.dart';
import 'memory_service.dart';
import 'topic_service.dart';
import 'alarm_controller.dart';

// ============================================================
// COMMAND RESULT
// ============================================================

class VayuCommandResult {
  final bool handled;
  final String message;
  final VayuCommandType commandType;
  final bool requiresConfirmation;

  const VayuCommandResult({
    required this.handled,
    required this.message,
    required this.commandType,
    this.requiresConfirmation = false,
  });

  factory VayuCommandResult.notHandled(
    String message,
  ) {
    return VayuCommandResult(
      handled: false,
      message: message,
      commandType: VayuCommandType.chat,
    );
  }
}

// ============================================================
// COMMAND CONTROLLER
// ============================================================

class CommandController {
  final CommandService _commandService;
  final MemoryService _memoryService;
  final TopicService _topicService;
  final AlarmController _alarmController;

  CommandController({
    required CommandService commandService,
    required MemoryService memoryService,
    required TopicService topicService,
    required AlarmController alarmController,
  })  : _commandService = commandService,
        _memoryService = memoryService,
        _topicService = topicService,
        _alarmController = alarmController;

  // ============================================================
  // HANDLE COMMAND
  // ============================================================

  Future<VayuCommandResult> handle(
    String text,
  ) async {
    final command =
        _commandService.parse(text);

    switch (command.type) {
      // ========================================================
      // MEMORY
      // ========================================================

      case VayuCommandType.saveMemory:
        return await _saveMemory(
          command,
        );

      case VayuCommandType.findMemory:
        return await _findMemory(
          command,
        );

      case VayuCommandType.deleteMemory:
        return await _deleteMemory(
          command,
        );

      case VayuCommandType.clearMemory:
        return const VayuCommandResult(
          handled: true,
          message:
              'Clearing all memories requires confirmation.',
          commandType:
              VayuCommandType.clearMemory,
          requiresConfirmation: true,
        );

      // ========================================================
      // TOPICS
      // ========================================================

      case VayuCommandType.saveTopic:
        return await _saveTopic(
          command,
        );

      case VayuCommandType.showTopics:
        return await _showTopics(
          command,
        );

      case VayuCommandType.searchTopic:
        return await _searchTopic(
          command,
        );

      case VayuCommandType.deleteTopic:
        return await _deleteTopic(
          command,
        );

      // ========================================================
      // ALARMS
      // ========================================================

      case VayuCommandType.setAlarm:
        return const VayuCommandResult(
          handled: true,
          message:
              'Alarm command detected. '
              'The alarm scheduler will handle the time.',
          commandType:
              VayuCommandType.setAlarm,
        );

      case VayuCommandType.showAlarms:
        return await _showAlarms(
          command,
        );

      case VayuCommandType.cancelAlarm:
        return const VayuCommandResult(
          handled: true,
          message:
              'Cancelling an alarm requires selecting '
              'or confirming the alarm.',
          commandType:
              VayuCommandType.cancelAlarm,
        );

      // ========================================================
      // NAVIGATION
      // ========================================================

      case VayuCommandType.openSettings:
      case VayuCommandType.openTopics:
      case VayuCommandType.openChat:
      case VayuCommandType.openHome:
        return VayuCommandResult(
          handled: true,
          message:
              'Navigation command detected.',
          commandType: command.type,
        );

      // ========================================================
      // VOICE
      // ========================================================

      case VayuCommandType.stopSpeaking:
        return const VayuCommandResult(
          handled: true,
          message: 'Stopping voice output.',
          commandType:
              VayuCommandType.stopSpeaking,
        );

      // ========================================================
      // LOCAL DATA
      // ========================================================

      case VayuCommandType.clearLocalData:
        return const VayuCommandResult(
          handled: true,
          message:
              'Clearing all local Vayu data requires '
              'confirmation.',
          commandType:
              VayuCommandType.clearLocalData,
          requiresConfirmation: true,
        );

      // ========================================================
      // NORMAL CHAT
      // ========================================================

      case VayuCommandType.chat:
        return VayuCommandResult.notHandled(
          'Normal conversation should be sent to Vayu AI.',
        );
    }
  }

  // ============================================================
  // SAVE MEMORY
  // ============================================================

  Future<VayuCommandResult> _saveMemory(
    VayuCommand command,
  ) async {
    final content =
        command.argument?.trim();

    if (content == null ||
        content.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'Tell me what you want me to remember.',
        commandType:
            VayuCommandType.saveMemory,
      );
    }

    await _memoryService.saveMemory(
      'memory_${DateTime.now().millisecondsSinceEpoch}',
      content,
    );

    return VayuCommandResult(
      handled: true,
      message:
          'I’ll keep that in Vayu memory: $content',
      commandType:
          VayuCommandType.saveMemory,
    );
  }

  // ============================================================
  // FIND MEMORY
  // ============================================================

  Future<VayuCommandResult> _findMemory(
    VayuCommand command,
  ) async {
    final memories =
        await _memoryService.getMemories();

    if (memories.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'I don’t have any saved memories yet.',
        commandType:
            VayuCommandType.findMemory,
      );
    }

    final buffer =
        StringBuffer(
      'Here are the memories stored locally:\n',
    );

    for (final memory in memories) {
      buffer.write(
        '• ${memory.value}\n',
      );
    }

    return VayuCommandResult(
      handled: true,
      message: buffer.toString().trim(),
      commandType:
          VayuCommandType.findMemory,
    );
  }

  // ============================================================
  // DELETE MEMORY
  // ============================================================

  Future<VayuCommandResult> _deleteMemory(
    VayuCommand command,
  ) async {
    final argument =
        command.argument?.trim();

    if (argument == null ||
        argument.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'Tell me which memory you want to forget.',
        commandType:
            VayuCommandType.deleteMemory,
      );
    }

    final memories =
        await _memoryService.search(
      argument,
    );

    if (memories.isEmpty) {
      return VayuCommandResult(
        handled: true,
        message:
            'I couldn’t find a memory matching "$argument".',
        commandType:
            VayuCommandType.deleteMemory,
      );
    }

    return VayuCommandResult(
      handled: true,
      message:
          'I found a matching memory. '
          'Confirmation will be required before deleting it.',
      commandType:
          VayuCommandType.deleteMemory,
      requiresConfirmation: true,
    );
  }

  // ============================================================
  // SAVE TOPIC
  // ============================================================

  Future<VayuCommandResult> _saveTopic(
    VayuCommand command,
  ) async {
    final content =
        command.argument?.trim();

    if (content == null ||
        content.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'Tell me what topic or note you want to save.',
        commandType:
            VayuCommandType.saveTopic,
      );
    }

    final now =
        DateTime.now();

    final topic =
        SavedTopic(
      id:
          'topic_${now.millisecondsSinceEpoch}',
      title:
          _createTopicTitle(content),
      content: content,
      createdAt: now,
      updatedAt: now,
      tags: const [],
      pinned: false,
    );

    await _topicService.saveTopic(
      topic,
    );

    return VayuCommandResult(
      handled: true,
      message:
          'Topic saved: ${topic.title}',
      commandType:
          VayuCommandType.saveTopic,
    );
  }

  // ============================================================
  // SHOW TOPICS
  // ============================================================

  Future<VayuCommandResult> _showTopics(
    VayuCommand command,
  ) async {
    final topics =
        await _topicService.getTopics();

    if (topics.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'You don’t have any saved topics yet.',
        commandType:
            VayuCommandType.showTopics,
      );
    }

    final buffer =
        StringBuffer(
      'Saved topics:\n',
    );

    for (final topic in topics) {
      final pinned =
          topic.pinned ? '📌 ' : '';

      buffer.write(
        '$pinned${topic.title}\n',
      );
    }

    return VayuCommandResult(
      handled: true,
      message: buffer.toString().trim(),
      commandType:
          VayuCommandType.showTopics,
    );
  }

  // ============================================================
  // SEARCH TOPIC
  // ============================================================

  Future<VayuCommandResult> _searchTopic(
    VayuCommand command,
  ) async {
    final query =
        command.argument?.trim();

    if (query == null ||
        query.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'Tell me what topic you want to search for.',
        commandType:
            VayuCommandType.searchTopic,
      );
    }

    final topics =
        await _topicService.searchTopics(
      query,
    );

    if (topics.isEmpty) {
      return VayuCommandResult(
        handled: true,
        message:
            'No saved topic matches "$query".',
        commandType:
            VayuCommandType.searchTopic,
      );
    }

    final buffer =
        StringBuffer(
      'Matching topics:\n',
    );

    for (final topic in topics) {
      buffer.write(
        '• ${topic.title}\n',
      );
    }

    return VayuCommandResult(
      handled: true,
      message: buffer.toString().trim(),
      commandType:
          VayuCommandType.searchTopic,
    );
  }

  // ============================================================
  // DELETE TOPIC
  // ============================================================

  Future<VayuCommandResult> _deleteTopic(
    VayuCommand command,
  ) async {
    final query =
        command.argument?.trim();

    if (query == null ||
        query.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'Tell me which topic you want to delete.',
        commandType:
            VayuCommandType.deleteTopic,
      );
    }

    final topics =
        await _topicService.searchTopics(
      query,
    );

    if (topics.isEmpty) {
      return VayuCommandResult(
        handled: true,
        message:
            'I couldn’t find a topic matching "$query".',
        commandType:
            VayuCommandType.deleteTopic,
      );
    }

    return VayuCommandResult(
      handled: true,
      message:
          'I found ${topics.length} matching topic(s). '
          'Confirmation is required before deletion.',
      commandType:
          VayuCommandType.deleteTopic,
      requiresConfirmation: true,
    );
  }

  // ============================================================
  // SHOW ALARMS
  // ============================================================

  Future<VayuCommandResult> _showAlarms(
    VayuCommand command,
  ) async {
    final alarms =
        await _alarmController.getAlarms();

    if (alarms.isEmpty) {
      return const VayuCommandResult(
        handled: true,
        message:
            'There are no saved alarms.',
        commandType:
            VayuCommandType.showAlarms,
      );
    }

    final buffer =
        StringBuffer(
      'Your alarms:\n',
    );

    for (final alarm in alarms) {
      final time =
          _formatDateTime(
        alarm.scheduledTime,
      );

      final label =
          alarm.label == null ||
                  alarm.label!.trim().isEmpty
              ? ''
              : ' — ${alarm.label}';

      final status =
          alarm.enabled
              ? 'enabled'
              : 'disabled';

      buffer.write(
        '• $time$label [$status]\n',
      );
    }

    return VayuCommandResult(
      handled: true,
      message: buffer.toString().trim(),
      commandType:
          VayuCommandType.showAlarms,
    );
  }

  // ============================================================
  // TOPIC TITLE
  // ============================================================

  String _createTopicTitle(
    String content,
  ) {
    final words =
        content
            .trim()
            .split(RegExp(r'\s+'));

    if (words.length <= 7) {
      return content.trim();
    }

    return '${words.take(7).join(' ')}...';
  }

  // ============================================================
  // DATE / TIME FORMAT
  // ============================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final hour =
        dateTime.hour == 0
            ? 12
            : dateTime.hour > 12
                ? dateTime.hour - 12
                : dateTime.hour;

    final minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }
}
