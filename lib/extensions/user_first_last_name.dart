import 'package:firebase_auth/firebase_auth.dart';

extension UserFirstLastName on User {
  String get firstName {
    if (displayName == null || displayName!.isEmpty) {
      return '';
    }

    final split = displayName!.split(' ');
    if (split.length < 1) {
      return '';
    }

    return split[0];
  }

  String get lastName {
    if (displayName == null || displayName!.isEmpty) {
      return '';
    }

    final split = displayName!.split(' ');
    if (split.length <= 1) {
      return '';
    }

    return split[1];
  }
}