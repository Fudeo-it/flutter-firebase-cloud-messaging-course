// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension ChatCopyWith on Chat {
  Chat copyWith({
    DateTime? createdAt,
    String? id,
    String? lastMessage,
    DateTime? updatedAt,
    User? user,
  }) {
    return Chat(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
