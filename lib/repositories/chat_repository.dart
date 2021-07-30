import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telegram_app/exceptions/chat_repository_exception.dart';
import 'package:telegram_app/extensions/future_map.dart';
import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/chat.dart';
import 'package:telegram_app/models/user.dart';

class ChatRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseMapper<Chat> chatMapper;
  final FirebaseMapper<User> userMapper;

  ChatRepository({
    required this.firebaseFirestore,
    required this.chatMapper,
    required this.userMapper,
  });

  Stream<List<Chat>> chats(String uid) => firebaseFirestore
      .collection('chats')
      .where('users',
          arrayContainsAny: [firebaseFirestore.collection('users').doc(uid)])
      .snapshots()
      .asyncMap(
        (snapshot) => snapshot.docs.futureMap<Chat>(
          (chatSnapshot) async {
            final chat = chatMapper.fromFirebase(chatSnapshot.data());

            final userReference = (chatSnapshot.data()['users'] as List)
                .firstWhere((userReference) => userReference.id != uid,
                    orElse: () => null);

            if (userReference == null) {
              throw new ChatRepositoryException();
            }

            final userSnapshot = await userReference.get();
            final user = userMapper
                .fromFirebase(userSnapshot.data())
                .copyWith(id: userSnapshot.id);

            return chat.copyWith(
              user: user,
              id: chatSnapshot.id,
            );
          },
        ),
      );

  Future<Chat> create({
    required String me,
    required String other,
    required String message,
  }) async {
    final users = [
      me,
      other,
    ]..sort();
    final List<DocumentReference> references = users
        .map<DocumentReference>(
            (id) => firebaseFirestore.collection('users').doc(id))
        .toList(growable: false);

    final insert = (await firebaseFirestore.collection('chats').add({
      'last_message': message,
      'users': references,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': null,
    }));

    final chatMapped = await insert.get();
    final chat = chatMapper.fromFirebase(chatMapped.data() ?? {});

    final userReference =
        ((chatMapped.data() ?? {'users': []})['users'] as List).firstWhere(
            (userSnapshot) => userSnapshot.id != me,
            orElse: () => null);

    if (userReference == null) {
      throw new ChatRepositoryException();
    }

    final userMapped = await userReference.get();
    final user = userMapper
        .fromFirebase(userMapped.data() ?? {})
        .copyWith(id: userReference.id);

    return chat.copyWith(
      id: chatMapped.id,
      user: user,
    );
  }

  Future<List<Chat>> find(String me, {required String other}) async {
    final users = [
      me,
      other,
    ]..sort();
    final List<DocumentReference> references = users
        .map<DocumentReference>(
            (id) => firebaseFirestore.collection('users').doc(id))
        .toList(growable: false);

    return (await firebaseFirestore
            .collection('chats')
            .where('users', isEqualTo: references)
            .get())
        .docs
        .futureMap<Chat>((chatSnapshot) async {
      final chat = chatMapper.fromFirebase(chatSnapshot.data());

      final userReference = ((chatSnapshot.data())['users'] as List).firstWhere(
          (userSnapshot) => userSnapshot.id != me,
          orElse: () => null);

      if (userReference == null) {
        throw new ChatRepositoryException();
      }

      final userMapped = await userReference.get();
      final user = userMapper
          .fromFirebase(userMapped.data() ?? {})
          .copyWith(id: userReference.id);

      return chat.copyWith(
        id: chatSnapshot.id,
        user: user,
      );
    });
  }

  Future<void> update({required String chat, String? lastMessage}) =>
      firebaseFirestore.collection('chats').doc(chat).update({
        'last_message': lastMessage ?? '',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

  Future<void> delete(String chat) =>
      firebaseFirestore.collection('chats').doc(chat).delete();
}
