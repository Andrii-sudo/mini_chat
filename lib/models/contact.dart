import 'package:flutter/material.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final String? lastSeen;
  final bool isSelected;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.avatarColor,
    this.isOnline = false,
    this.lastSeen,
    this.isSelected = false,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? initials,
    Color? avatarColor,
    bool? isOnline,
    String? lastSeen,
    bool? isSelected,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      avatarColor: avatarColor ?? this.avatarColor,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      initials: json['initials'] as String,
      avatarColor: Color(json['avatarColor'] as int),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'initials': initials,
      'avatarColor': avatarColor.value,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'isSelected': isSelected,
    };
  }
}