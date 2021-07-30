import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/message.dart';

class MessageFirebaseMapper extends FirebaseMapper<Message> {
  @override
  Message fromFirebase(Map<String, dynamic> map) => Message(
        message: map['message'],
        sender: map['sender'],
        attachmentUrl: map['attachment'],
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
            : null,
      );

  @override
  Map<String, dynamic> toFirebase(Message object) {
    throw UnimplementedError();
  }
}
