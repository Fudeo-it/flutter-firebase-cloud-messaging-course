import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telegram_app/extensions/future_map.dart';
import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/friend.dart';
import 'package:telegram_app/models/user.dart';

class FriendRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseMapper<Friend> friendMapper;
  final FirebaseMapper<User> userMapper;

  FriendRepository({
    required this.firebaseFirestore,
    required this.friendMapper,
    required this.userMapper,
  });

  Future<void> create({
    required String me,
    required String user,
  }) =>
      firebaseFirestore.collection('friends').add({
        'allowed': true,
        'user': me,
        'friend': firebaseFirestore.collection('users').doc(user)
      });

  Future<List<Friend>> friends(String uid) async => (await firebaseFirestore
              .collection('friends')
              .where('user', isEqualTo: uid)
              .get())
          .docs
          .futureMap<Friend>((friendSnapshot) async {
        final userReference = friendSnapshot.data()['friend']
            as DocumentReference<Map<String, dynamic>>;
        final userSnapshot = await userReference.get();

        final user = userMapper
            .fromFirebase(userSnapshot.data() ?? {})
            .copyWith(id: userReference.id);

        return friendMapper
            .fromFirebase(friendSnapshot.data())
            .copyWith(id: friendSnapshot.id)
            .copyWith(user: user);
      });

  Future<bool> isFriend({
    required String me,
    required String user,
  }) async =>
      (await firebaseFirestore
              .collection('friends')
              .where('user', isEqualTo: me)
              .where('friend',
                  isEqualTo: firebaseFirestore.collection('users').doc(user))
              .get())
          .size >
      0;
}
