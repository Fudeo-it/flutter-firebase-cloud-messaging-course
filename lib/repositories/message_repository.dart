import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:telegram_app/exceptions/upload_failed_exception.dart';
import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/message.dart';

class MessageRepository {
  final FirebaseDatabase firebaseDatabase;
  final FirebaseStorage firebaseStorage;
  final FirebaseMapper<Message> messageMapper;

  MessageRepository({
    required this.firebaseDatabase,
    required this.firebaseStorage,
    required this.messageMapper,
  });

  DatabaseReference _messages(String chat) =>
      firebaseDatabase.reference().child('messages/$chat');

  DatabaseReference _message(String message, {required String chat}) =>
      firebaseDatabase.reference().child('messages/$chat/$message');

  Stream<List<Message>> messages(String chat) => _messages(chat).onValue.map(
        (event) => ((event.snapshot.value ?? {}) as Map)
            .map<String, Message>(
              (key, value) => MapEntry(
                key,
                messageMapper
                    .fromFirebase(Map<String, dynamic>.from(value))
                    .copyWith(id: key),
              ),
            )
            .values
            .toList(growable: false)
            .reversed
            .toList(growable: false),
      );

  Future<void> send(
    String chat, {
    required String sender,
    required String message,
    File? attachment,
  }) async {
    String? attachmentUrl;
    if (attachment != null) {
      attachmentUrl = await _uploadAttachment(attachment, chat: chat);
    }

    return _messages(chat).push().set({
      'sender': sender,
      'message': message,
      'attachment': attachmentUrl,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': null,
    });
  }

  Future<void> update(
    String id, {
    required String chat,
    required String message,
  }) async {
    final reference = _message(id, chat: chat);
    final Map entry = (await reference.once()).value;

    entry.addAll({
      'message': message,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    return reference.set(entry);
  }

  Future<void> clean(String chat) => _messages(chat).remove();

  Future<void> delete({required String chat, required String message}) async {
    final reference = _message(message, chat: chat);
    final Map entry = (await reference.once()).value;

    if (entry.containsKey('attachment')) {
      await firebaseStorage.refFromURL(entry['attachment']).delete();
    }

    return _message(message, chat: chat).remove();
  }

  Future<String> _uploadAttachment(File file, {required String chat}) async {
    try {
      final Reference ref = firebaseStorage.ref(
          '/chats/$chat/attachments/${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}');
      await ref.putFile(file);

      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      Fimber.e('Cannot upload attachment: $e');

      throw new UploadFailedException();
    }
  }
}
