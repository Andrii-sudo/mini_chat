import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 0)
class Chat {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String lastMessage;

  @HiveField(3)
  final String time;

  @HiveField(4)
  final String initials;

  @HiveField(5)
  final int avatarColorValue;

  @HiveField(6)
  final bool isOnline;

  @HiveField(7)
  final int? unreadCount;

  @HiveField(8)
  final bool isGroup;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.initials,
    required this.avatarColorValue,
    this.isOnline = false,
    this.unreadCount,
    this.isGroup = false,
  });

  Chat.withColor({
    required String id,
    required String name,
    required String lastMessage,
    required String time,
    required String initials,
    required Color avatarColor,
    bool isOnline = false,
    int? unreadCount,
    bool isGroup = false,
  }) : this(
    id: id,
    name: name,
    lastMessage: lastMessage,
    time: time,
    initials: initials,
    avatarColorValue: avatarColor.value,
    isOnline: isOnline,
    unreadCount: unreadCount,
    isGroup: isGroup,
  );

  Color get avatarColor => Color(avatarColorValue);

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      time: json['time'] as String,
      initials: json['initials'] as String,
      avatarColorValue: json['avatarColor'] as int,
      isOnline: json['isOnline'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int?,
      isGroup: json['isGroup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'time': time,
      'initials': initials,
      'avatarColor': avatarColorValue,
      'isOnline': isOnline,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
    };
  }
}