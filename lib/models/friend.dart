import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:telegram_app/models/model.dart';
import 'package:telegram_app/models/user.dart';

part 'friend.g.dart';

@CopyWith()
class Friend extends Model {
  final User? user;
  final bool allowed;

  Friend({
    String? id,
    this.user,
    required this.allowed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        user,
        allowed,
      ];
}
