import 'package:equatable/equatable.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatsEvent extends ChatsEvent {
  const LoadChatsEvent();
}

class RefreshChatsEvent extends ChatsEvent {
  const RefreshChatsEvent();
}

class SearchChatsEvent extends ChatsEvent {
  final String query;

  const SearchChatsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadChatsWithErrorEvent extends ChatsEvent {
  const LoadChatsWithErrorEvent();
}

class ChatsUpdatedEvent extends ChatsEvent {
  final List<Map<String, dynamic>> chatsData;

  const ChatsUpdatedEvent(this.chatsData);

  @override
  List<Object?> get props => [chatsData];
}