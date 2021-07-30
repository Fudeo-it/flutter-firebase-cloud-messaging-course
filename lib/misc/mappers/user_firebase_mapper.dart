import 'package:telegram_app/misc/mappers/firebase_mapper.dart';
import 'package:telegram_app/models/user.dart';

class UserFirebaseMapper extends FirebaseMapper<User> {
  @override
  User fromFirebase(Map<String, dynamic> map) => User(
        firstName: map['first_name'],
        lastName: map['last_name'],
        avatar: map['avatar'],
        lastAccess: map['last_access'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['last_access'])
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
            : null,
      );

  @override
  Map<String, dynamic> toFirebase(User user) => {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'avatar': user.avatar,
        'last_access': user.lastAccess?.millisecondsSinceEpoch,
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'updated_at': user.updatedAt?.millisecondsSinceEpoch,
      };
}
