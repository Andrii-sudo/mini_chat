import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat.dart';

class CacheService {
  static const String _chatsBoxName = 'chats_cache';
  static const String _prefsBoxName = 'preferences';

  Box<Chat>? _chatsBox;
  Box? _prefsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatAdapter());
    }

    _chatsBox = await Hive.openBox<Chat>(_chatsBoxName);
    _prefsBox = await Hive.openBox(_prefsBoxName);
  }


  Future<void> cacheChats(List<Chat> chats) async {
    final box = _chatsBox ?? await Hive.openBox<Chat>(_chatsBoxName);
    await box.clear();

    for (var chat in chats) {
      await box.put(chat.id, chat);
    }
  }

  List<Chat> getCachedChats() {
    final box = _chatsBox ?? Hive.box<Chat>(_chatsBoxName);
    return box.values.toList();
  }

  bool hasCachedChats() {
    final box = _chatsBox ?? Hive.box<Chat>(_chatsBoxName);
    return box.isNotEmpty;
  }

  Future<void> updateCachedChat(Chat chat) async {
    final box = _chatsBox ?? await Hive.openBox<Chat>(_chatsBoxName);
    await box.put(chat.id, chat);
  }

  Future<void> deleteCachedChat(String chatId) async {
    final box = _chatsBox ?? await Hive.openBox<Chat>(_chatsBoxName);
    await box.delete(chatId);
  }

  Future<void> clearChatsCache() async {
    final box = _chatsBox ?? await Hive.openBox<Chat>(_chatsBoxName);
    await box.clear();
  }


  Future<void> saveLastSearchQuery(String query) async {
    final box = _prefsBox ?? await Hive.openBox(_prefsBoxName);
    await box.put('last_search_query', query);
  }

  String? getLastSearchQuery() {
    final box = _prefsBox ?? Hive.box(_prefsBoxName);
    return box.get('last_search_query') as String?;
  }

  Future<void> saveLastOpenedChatId(String chatId) async {
    final box = _prefsBox ?? await Hive.openBox(_prefsBoxName);
    await box.put('last_chat_id', chatId);
  }

  String? getLastOpenedChatId() {
    final box = _prefsBox ?? Hive.box(_prefsBoxName);
    return box.get('last_chat_id') as String?;
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final box = _prefsBox ?? await Hive.openBox(_prefsBoxName);
    await box.put('is_dark_mode', isDarkMode);
  }

  bool isDarkMode() {
    final box = _prefsBox ?? Hive.box(_prefsBoxName);
    return box.get('is_dark_mode', defaultValue: false) as bool;
  }

  Future<void> clearPreferences() async {
    final box = _prefsBox ?? await Hive.openBox(_prefsBoxName);
    await box.clear();
  }

  Future<void> clearAll() async {
    await clearChatsCache();
    await clearPreferences();
  }

  Future<void> close() async {
    await _chatsBox?.close();
    await _prefsBox?.close();
  }
}