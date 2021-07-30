import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/chat.dart';

class ChatFirebaseMapper extends FirebaseMapper<Chat> {
  @override
  Chat fromFirebase(Map<String, dynamic> map) => Chat(
        lastMessage: map['last_message'],
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
            : null,
      );

  @override
  Map<String, dynamic> toFirebase(Chat object) {
    // TODO: implement toFirebase
    throw UnimplementedError();
  }
}
