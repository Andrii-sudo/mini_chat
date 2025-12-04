import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'chats_event.dart';
import 'chats_state.dart';
import '../models/chat.dart';
import '../services/cache_service.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final CacheService _cacheService = CacheService();

  ChatsBloc() : super(const ChatsInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<RefreshChatsEvent>(_onRefreshChats);
    on<SearchChatsEvent>(_onSearchChats);
    on<LoadChatsWithErrorEvent>(_onLoadChatsWithError);
  }

  List<Chat> _allChats = [];

  Future<void> _onLoadChats(
      LoadChatsEvent event,
      Emitter<ChatsState> emit,
      ) async {
    if (_cacheService.hasCachedChats()) {
      final cachedChats = _cacheService.getCachedChats();
      _allChats = cachedChats;
      emit(ChatsLoadedState(data: cachedChats));

      print('Завантажено ${cachedChats.length} чатів з кешу');
    } else {
      emit(ChatsLoadingState(data: state.data));
    }

    try {
      await Future.delayed(const Duration(seconds: 1)); // Симуляція API запиту

      _allChats = [
        Chat.withColor(
          id: '1',
          name: 'Олена Коваль',
          lastMessage: 'Привіт!',
          time: '10:30',
          avatarColor: const Color(0xFF4CAF50),
          initials: 'ОК',
          isOnline: true,
        ),
        Chat.withColor(
          id: '2',
          name: 'Група ПЗ-33',
          lastMessage: 'Марія: Коли здаємо лабу?',
          time: 'Вчора',
          avatarColor: const Color(0xFFFF9800),
          initials: 'ПЗ',
          unreadCount: 2,
          isGroup: true,
        ),
        Chat.withColor(
          id: '3',
          name: 'Іван Шевченко',
          lastMessage: 'Ви: Добре, домовились',
          time: 'Пн',
          avatarColor: const Color(0xFF2196F3),
          initials: 'ІШ',
        ),
        Chat.withColor(
          id: '4',
          name: 'Марія Петренко',
          lastMessage: 'Дякую за допомогу!',
          time: 'Вт',
          avatarColor: const Color(0xFFFF5722),
          initials: 'МП',
        ),
        Chat.withColor(
          id: '5',
          name: 'Тарас Коваленко',
          lastMessage: 'Побачимось завтра',
          time: 'Ср',
          avatarColor: const Color(0xFF9C27B0),
          initials: 'ТК',
        ),
        Chat.withColor(
          id: '6',
          name: 'Андрій Мельник',
          lastMessage: 'Відправив файли',
          time: 'Чт',
          avatarColor: const Color(0xFFE91E63),
          initials: 'АМ',
          isOnline: true,
        ),
      ];

      await _cacheService.cacheChats(_allChats);
      print('Збережено ${_allChats.length} чатів у кеш');

      emit(ChatsLoadedState(data: _allChats));
    } catch (e) {
      emit(ChatsErrorState(
        error: 'Помилка завантаження чатів: $e',
        data: state.data,
      ));
    }
  }

  Future<void> _onRefreshChats(
      RefreshChatsEvent event,
      Emitter<ChatsState> emit,
      ) async {
    emit(ChatsLoadingState(data: state.data));

    try {
      // симуляція api
      await Future.delayed(const Duration(seconds: 1));

      await _cacheService.cacheChats(_allChats);
      print('Оновлено кеш чатів');

      emit(ChatsLoadedState(data: _allChats));
    } catch (e) {
      emit(ChatsErrorState(
        error: 'Помилка оновлення чатів: $e',
        data: state.data,
      ));
    }
  }

  Future<void> _onSearchChats(
      SearchChatsEvent event,
      Emitter<ChatsState> emit,
      ) async {
    // Зберігаємо пошуковий запит
    if (event.query.isNotEmpty) {
      await _cacheService.saveLastSearchQuery(event.query);
    }

    if (event.query.isEmpty) {
      emit(ChatsLoadedState(data: _allChats));
      return;
    }

    final query = event.query.toLowerCase();
    final filteredChats = _allChats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();

    emit(ChatsLoadedState(data: filteredChats));
  }

  // Обробка тестової помилки
  Future<void> _onLoadChatsWithError(
      LoadChatsWithErrorEvent event,
      Emitter<ChatsState> emit,
      ) async {
    emit(ChatsLoadingState(data: state.data));

    await Future.delayed(const Duration(seconds: 1));

    emit(const ChatsErrorState(
      error: 'Тестова помилка завантаження чатів',
      data: [],
    ));
  }
}