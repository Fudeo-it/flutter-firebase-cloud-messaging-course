import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:telegram_app/services/image_picker_service.dart';

part 'image_picker_event.dart';

part 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final ImagePickerService imagePickerService;

  ImagePickerBloc({required this.imagePickerService})
      : super(NoImagePickedState());

  File? get pickedImage =>
      state is PickedImageState ? (state as PickedImageState).imageFile : null;

  @override
  Stream<ImagePickerState> mapEventToState(
    ImagePickerEvent event,
  ) async* {
    if (event is PickCameraImageEvent) {
      yield* _mapPickCameraImageEventToState(event);
    } else if (event is PickGalleryImageEvent) {
      yield* _mapPickGalleryImageEventToState(event);
    } else if (event is ResetImageEvent) {
      yield* _mapResetImageEventToState(event);
    }
  }

  Stream<ImagePickerState> _mapPickCameraImageEventToState(
      PickCameraImageEvent event) async* {
    yield LoadingImageState();

    final imageFile = await imagePickerService.pickImageFromCamera();

    if (imageFile != null) {
      yield PickedImageState(imageFile);
    } else {
      yield NoImagePickedState();
    }
  }

  Stream<ImagePickerState> _mapPickGalleryImageEventToState(
      PickGalleryImageEvent event) async* {
    yield LoadingImageState();

    final imageFile = await imagePickerService.pickImageFromGallery();

    if (imageFile != null) {
      yield PickedImageState(imageFile);
    } else {
      yield NoImagePickedState();
    }
  }

  Stream<ImagePickerState> _mapResetImageEventToState(
      ResetImageEvent event) async* {
    yield NoImagePickedState();
  }

  void pickCameraImage() => add(PickCameraImageEvent());

  void pickGalleryImage() => add(PickGalleryImageEvent());

  void reset() => add(ResetImageEvent());
}
