import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:telegram_app/models/model.dart';

part 'user.g.dart';

@CopyWith()
class User extends Model {
  final String firstName;
  final String lastName;
  final DateTime? lastAccess;
  final String? avatar;

  User({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.lastAccess,
    this.avatar,
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
        avatar,
        firstName,
        lastName,
        lastAccess,
      ];

  String get initials =>
      firstName.substring(0, 1).toUpperCase() +
      lastName.substring(0, 1).toUpperCase();

  String get displayName => '$firstName $lastName';

  String get firstLetter => firstName.substring(0, 1);
}
