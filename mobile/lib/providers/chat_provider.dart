import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/local_cache_service.dart';
import 'orb_state_provider.dart';
import 'language_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  // TODO: move base URL to flavor-specific config (dev/staging/prod).
  return ApiService(
    baseUrl: 'https://asia-south1-vayu-ai.cloudfunctions.net/api',
  );
});

final localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._ref) : super([]) {
    _loadCached();
  }

  final Ref _ref;
  String? _conversationId;
  String? _error;

  String? get error => _error;
  String get _cacheKey => _conversationId ?? 'draft';

  void _loadCached() {
    final cached = _ref.read(localCacheProvider).getCachedMessages('draft');
    if (cached.isNotEmpty) state = cached;
  }

  Future<void> _persist() {
    return _ref.read(localCacheProvider).cacheMessages(_cacheKey, state);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final language = _ref.read(languageProvider);

    state = [...state, ChatMessage.user(text)];
    _error = null;
    _ref.read(orbStateProvider.notifier).setThinking();
    await _persist();

    try {
      final api = _ref.read(apiServiceProvider);
      final result = await api.sendMessage(
        message: text,
        conversationId: _conversationId,
        language: language,
      );
      _conversationId = result.conversationId;

      // Auto-translate the reply if the user's preferred language isn't English.
      String? translated;
      if (language != 'en') {
        try {
          translated = await api.translateText(result.reply, language);
        } catch (_) {
          // Translation failing shouldn't block showing the English reply.
          translated = null;
        }
      }

      state = [
        ...state,
        ChatMessage.assistant(result.reply, translatedContent: translated),
      ];
      _ref.read(orbStateProvider.notifier).setSpeaking();
      await _persist();
    } on RateLimitException catch (e) {
      _error = e.message;
      _ref.read(orbStateProvider.notifier).setIdle();
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _ref.read(orbStateProvider.notifier).setIdle();
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});
