class VayuAlarm {
  final String id;
  final DateTime scheduledTime;
  final String? label;
  final bool enabled;

  const VayuAlarm({
    required this.id,
    required this.scheduledTime,
    this.label,
    this.enabled = true,
  });

  VayuAlarm copyWith({
    DateTime? scheduledTime,
    String? label,
    bool? enabled,
  }) {
    return VayuAlarm(
      id: id,
      scheduledTime:
          scheduledTime ?? this.scheduledTime,
      label: label ?? this.label,
      enabled:
          enabled ?? this.enabled,
    );
  }
}

class AlarmService {
  final List<VayuAlarm> _alarms = [];

  // ============================================================
  // GET ALARMS
  // ============================================================

  List<VayuAlarm> getAlarms() {
    final alarms =
        List<VayuAlarm>.from(_alarms);

    alarms.sort(
      (a, b) => a.scheduledTime.compareTo(
        b.scheduledTime,
      ),
    );

    return alarms;
  }

  // ============================================================
  // SET ALARM
  // ============================================================

  VayuAlarm setAlarm({
    required DateTime scheduledTime,
    String? label,
  }) {
    if (scheduledTime.isBefore(
      DateTime.now(),
    )) {
      throw ArgumentError(
        'Alarm time must be in the future.',
      );
    }

    final alarm = VayuAlarm(
      id: _generateId(),
      scheduledTime: scheduledTime,
      label: label?.trim().isEmpty == true
          ? null
          : label?.trim(),
    );

    _alarms.add(alarm);

    return alarm;
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  bool cancelAlarm(
    String alarmId,
  ) {
    final initialLength =
        _alarms.length;

    _alarms.removeWhere(
      (alarm) => alarm.id == alarmId,
    );

    return _alarms.length !=
        initialLength;
  }

  // ============================================================
  // ENABLE / DISABLE ALARM
  // ============================================================

  bool setAlarmEnabled(
    String alarmId,
    bool enabled,
  ) {
    final index =
        _alarms.indexWhere(
      (alarm) => alarm.id == alarmId,
    );

    if (index < 0) {
      return false;
    }

    _alarms[index] =
        _alarms[index].copyWith(
      enabled: enabled,
    );

    return true;
  }

  // ============================================================
  // FIND ALARM
  // ============================================================

  VayuAlarm? getAlarm(
    String alarmId,
  ) {
    try {
      return _alarms.firstWhere(
        (alarm) => alarm.id == alarmId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // NEXT ALARM
  // ============================================================

  VayuAlarm? getNextAlarm() {
    final now =
        DateTime.now();

    final upcoming = _alarms
        .where(
          (alarm) =>
              alarm.enabled &&
              alarm.scheduledTime.isAfter(
                now,
              ),
        )
        .toList();

    if (upcoming.isEmpty) {
      return null;
    }

    upcoming.sort(
      (a, b) =>
          a.scheduledTime.compareTo(
        b.scheduledTime,
      ),
    );

    return upcoming.first;
  }

  // ============================================================
  // CLEAR ALL ALARMS
  // ============================================================

  void clearAllAlarms() {
    _alarms.clear();
  }

  // ============================================================
  // COMMAND DETECTION
  // ============================================================

  bool isAlarmCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.contains(
          'set an alarm',
        ) ||
        command.contains(
          'set alarm',
        ) ||
        command.contains(
          'wake me',
        ) ||
        command.contains(
          'alarm for',
        );
  }

  bool isCancelAlarmCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.contains(
          'cancel alarm',
        ) ||
        command.contains(
          'delete alarm',
        ) ||
        command.contains(
          'remove alarm',
        ) ||
        command.contains(
          'cancel my alarm',
        );
  }

  bool isShowAlarmCommand(
    String text,
  ) {
    final command =
        text.trim().toLowerCase();

    return command.contains(
          'show alarms',
        ) ||
        command.contains(
          'show my alarms',
        ) ||
        command.contains(
          'what alarms',
        ) ||
        command.contains(
          'next alarm',
        );
  }
    // ============================================================
  // RESTORE STORED ALARM
  // ============================================================

  void restoreAlarm(
    VayuAlarm alarm,
  ) {
    if (alarm.scheduledTime.isBefore(
      DateTime.now(),
    )) {
      return;
    }

    final exists =
        _alarms.any(
      (item) => item.id == alarm.id,
    );

    if (!exists) {
      _alarms.add(alarm);
    }
  }

  // ============================================================
  // ID GENERATOR
  // ============================================================

  String _generateId() {
    return 'alarm_${DateTime.now().microsecondsSinceEpoch}';
  }
}
