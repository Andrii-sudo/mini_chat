import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chats_event.dart';
import 'chats_state.dart';
import '../models/chat.dart';
import '../services/cache_service.dart';
import '../services/firestore_service.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final CacheService _cacheService = CacheService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _chatsSubscription;
  List<Chat> _allChats = [];

  ChatsBloc() : super(const ChatsInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<RefreshChatsEvent>(_onRefreshChats);
    on<SearchChatsEvent>(_onSearchChats);
    on<LoadChatsWithErrorEvent>(_onLoadChatsWithError);
    on<ChatsUpdatedEvent>(_onChatsUpdated);
  }

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

    _subscribeToChats();
  }

  void _subscribeToChats() {
    _chatsSubscription?.cancel();

    _chatsSubscription = _firestoreService.getUserChats().listen(
          (chatsData) {
        add(ChatsUpdatedEvent(chatsData));
      },
      onError: (error) {
        print('Помилка отримання чатів: $error');
        add(const LoadChatsWithErrorEvent());
      },
    );
  }

  Future<void> _onChatsUpdated(
      ChatsUpdatedEvent event,
      Emitter<ChatsState> emit,
      ) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        emit(const ChatsLoadedState(data: []));
        return;
      }

      final chats = <Chat>[];

      for (var chatData in event.chatsData) {
        final chat = await _convertFirestoreChatToChat(chatData, currentUserId);
        if (chat != null) {
          chats.add(chat);
        }
      }

      _allChats = chats;

      await _cacheService.cacheChats(chats);
      print('Оновлено ${chats.length} чатів з Firestore');

      emit(ChatsLoadedState(data: chats));
    } catch (e) {
      print('Помилка обробки чатів: $e');
      emit(ChatsErrorState(
        error: 'Помилка завантаження чатів: $e',
        data: state.data,
      ));
    }
  }

  Future<Chat?> _convertFirestoreChatToChat(
      Map<String, dynamic> chatData,
      String currentUserId,
      ) async {
    try {
      final chatId = chatData['id'] as String;
      final participants = List<String>.from(chatData['participants'] ?? []);
      final participantDetails = Map<String, dynamic>.from(
          chatData['participantDetails'] ?? {}
      );

      final otherUserId = participants.firstWhere(
            (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) return null;

      final otherUserData = participantDetails[otherUserId];
      if (otherUserData == null) return null;

      final name = otherUserData['displayName'] ?? otherUserData['email'] ?? 'User';
      final email = otherUserData['email'] ?? '';

      String initials;
      if (name.isEmpty) {
        initials = email.isNotEmpty ? email[0].toUpperCase() : '?';
      } else {
        final parts = name.trim().split(' ');
        if (parts.length >= 2) {
          initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          initials = name[0].toUpperCase();
        }
      }

      final colors = [
        const Color(0xFF4CAF50),
        const Color(0xFF2196F3),
        const Color(0xFFFF9800),
        const Color(0xFF9C27B0),
        const Color(0xFFE91E63),
        const Color(0xFF00BCD4),
        const Color(0xFFFF5722),
      ];
      final colorIndex = otherUserId.hashCode.abs() % colors.length;
      final avatarColor = colors[colorIndex];

      final lastMessage = chatData['lastMessage'] ?? 'Почніть розмову';
      final lastMessageTime = chatData['lastMessageTime'];

      String timeString = '';
      if (lastMessageTime != null) {
        DateTime messageTime;
        if (lastMessageTime is String) {
          messageTime = DateTime.parse(lastMessageTime);
        } else {
          messageTime = (lastMessageTime as dynamic).toDate();
        }
        timeString = _formatTime(messageTime);
      }

      final otherUser = await _firestoreService.getUserById(otherUserId);
      final isOnline = otherUser?.isOnline ?? false;

      final unreadCounts = chatData['unreadCount'] as Map<String, dynamic>?;
      final unreadCount = unreadCounts?[currentUserId] as int? ?? 0;

      return Chat.withColor(
        id: chatId,
        name: name,
        lastMessage: lastMessage,
        time: timeString,
        avatarColor: avatarColor,
        initials: initials,
        isOnline: isOnline,
        unreadCount: unreadCount > 0 ? unreadCount : null,
        isGroup: false,
      );
    } catch (e) {
      print('Помилка конвертації чату: $e');
      return null;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Вчора';
    } else if (diff.inDays < 7) {
      final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.day}.${time.month}.${time.year}';
    }
  }

  Future<void> _onRefreshChats(
      RefreshChatsEvent event,
      Emitter<ChatsState> emit,
      ) async {
    emit(ChatsLoadingState(data: state.data));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(ChatsLoadedState(data: _allChats));
  }

  Future<void> _onSearchChats(
      SearchChatsEvent event,
      Emitter<ChatsState> emit,
      ) async {
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

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}