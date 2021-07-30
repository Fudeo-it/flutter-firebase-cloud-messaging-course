// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension MessageCopyWith on Message {
  Message copyWith({
    String? attachmentUrl,
    DateTime? createdAt,
    String? id,
    String? message,
    String? sender,
    DateTime? updatedAt,
  }) {
    return Message(
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
