import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/user.dart';

class UserRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseMapper<User> userMapper;

  UserRepository({
    required this.firebaseFirestore,
    required this.userMapper,
  });

  Stream<User> user(String uid) => firebaseFirestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .where((snapshot) => snapshot.exists)
      .asyncMap(
          (userStream) => userMapper.fromFirebase(userStream.data() ?? {}));

  Future<void> create(User user) async => firebaseFirestore
      .collection('users')
      .doc(user.id)
      .set(userMapper.toFirebase(user));

  Future<List<User>> search(String query) async => (await firebaseFirestore
          .collection('users')
          .where('last_name', isEqualTo: query)
          .get())
      .docs
      .map((snapshot) =>
          userMapper.fromFirebase(snapshot.data()).copyWith(id: snapshot.id))
      .toList(growable: false);

  Future<void> update(String uid, {String? token}) async {
    final ref = firebaseFirestore.collection('users').doc(uid);
    final user = await ref.get();

    final Map<String, dynamic>? entry = user.data();
    if (entry != null) {
      entry.addAll({
        'last_access': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (token != null) {
        entry.addAll({
          'tokens': (Set.from(entry['tokens'] ?? [])..add(token))
              .toList(growable: false)
        });
      }

      return ref.update(entry);
    }
  }
}
