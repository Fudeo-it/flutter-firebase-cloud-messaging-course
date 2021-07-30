part of 'image_picker_bloc.dart';

abstract class ImagePickerState extends Equatable {
  const ImagePickerState();

  @override
  List<Object> get props => [];
}

class NoImagePickedState extends ImagePickerState {
  
}

class LoadingImageState extends ImagePickerState {}

class PickedImageState extends ImagePickerState {
  final File imageFile;

  PickedImageState(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}