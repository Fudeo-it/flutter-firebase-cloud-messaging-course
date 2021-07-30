import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_essentials_kit/flutter_essentials_kit.dart';

class SearchCubit extends Cubit<bool> {

  final searchBinding = TwoWayBinding<String>();

  SearchCubit() : super(false);

  void toggle() => emit(!state);

  @override
  void onChange(Change<bool> change) {
    if (!change.nextState) {
      searchBinding.value = null;
    }

    super.onChange(change);
  }

  @override
  Future<void> close() async {
    await searchBinding.close();

    return super.close();
  }
}