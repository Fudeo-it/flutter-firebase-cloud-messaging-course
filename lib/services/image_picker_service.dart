import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File?> pickImageFromCamera() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.camera);
    return pickedImage != null ? File(pickedImage.path) : null;
  }

  Future<File?> pickImageFromGallery() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    return pickedImage != null ? File(pickedImage.path) : null;
  }
}