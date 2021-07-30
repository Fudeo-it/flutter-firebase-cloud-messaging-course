import 'dart:io';
import 'package:fimber/fimber.dart';
import 'package:path/path.dart' as path;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:telegram_app/exceptions/upload_failed_exception.dart';

class ProfileRepository {
  final FirebaseStorage firebaseStorage;

  ProfileRepository({required this.firebaseStorage});

  Future<String> uploadAvatar(File file, {required String id}) async {
    try {
      final Reference ref = firebaseStorage.ref('/users/$id/avatar${path.extension(file.path)}');
      await ref.putFile(file);

      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      Fimber.e('Cannot upload avatar: $e');

      throw new UploadFailedException();
    }
  }
}