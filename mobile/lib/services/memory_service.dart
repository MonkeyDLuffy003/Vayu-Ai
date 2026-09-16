import 'dart:convert';

import 'local_storage_service.dart';

class VayuMemory {
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VayuMemory({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VayuMemory.fromJson(Map<String, dynamic> json) {
    return VayuMemory(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      createdAt: DateTime.tryParse(
            json['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            json['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class MemoryService {
  final LocalStorageService _storage;

  static const String _memoryKey = 'vayu_memories';

  MemoryService(this._storage);

  /// Load all saved memories.
  Future<List<VayuMemory>> getMemories() async {
    final preferences = await _storage.preferences;
    final raw = preferences.getString(_memoryKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => VayuMemory.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save or update a memory.
  Future<void> saveMemory(
    String key,
    String value,
  ) async {
    final cleanKey = key.trim();
    final cleanValue = value.trim();

    if (cleanKey.isEmpty || cleanValue.isEmpty) {
      return;
    }

    final memories = await getMemories();
    final now = DateTime.now();

    final index = memories.indexWhere(
      (memory) => memory.key.toLowerCase() == cleanKey.toLowerCase(),
    );

    final memory = VayuMemory(
      key: cleanKey,
      value: cleanValue,
      createdAt: index >= 0
          ? memories[index].createdAt
          : now,
      updatedAt: now,
    );

    if (index >= 0) {
      memories[index] = memory;
    } else {
      memories.add(memory);
    }

    await _saveMemories(memories);
  }

  /// Find a memory by key.
  Future<VayuMemory?> getMemory(String key) async {
    final memories = await getMemories();

    try {
      return memories.firstWhere(
        (memory) =>
            memory.key.toLowerCase() == key.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Delete one memory.
  Future<void> deleteMemory(String key) async {
    final memories = await getMemories();

    memories.removeWhere(
      (memory) =>
          memory.key.toLowerCase() == key.trim().toLowerCase(),
    );

    await _saveMemories(memories);
  }

  /// Clear every local memory.
  Future<void> clearMemories() async {
    final preferences = await _storage.preferences;
    await preferences.remove(_memoryKey);
  }

  /// Search memories using text.
  Future<List<VayuMemory>> search(String query) async {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return getMemories();
    }

    final memories = await getMemories();

    return memories.where((memory) {
      return memory.key.toLowerCase().contains(cleanQuery) ||
          memory.value.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  Future<void> _saveMemories(
    List<VayuMemory> memories,
  ) async {
    final preferences = await _storage.preferences;

    final encoded = jsonEncode(
      memories.map((memory) => memory.toJson()).toList(),
    );

    await preferences.setString(
      _memoryKey,
      encoded,
    );
  }
}
