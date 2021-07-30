part of 'image_picker_bloc.dart';

abstract class ImagePickerEvent extends Equatable {
  const ImagePickerEvent();

  @override
  List<Object?> get props => [];
}

class PickCameraImageEvent extends ImagePickerEvent {}

class PickGalleryImageEvent extends ImagePickerEvent {}

class ResetImageEvent extends ImagePickerEvent {}