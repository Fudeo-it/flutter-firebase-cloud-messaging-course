import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:telegram_app/models/model.dart';
import 'package:telegram_app/models/user.dart';

part 'chat.g.dart';

@CopyWith()
class Chat extends Model {
  final User? user;
  final String lastMessage;

  Chat({
    String? id,
    this.user,
    required this.lastMessage,
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
        lastMessage,
      ];

  String get initials => user != null ? user!.initials : '';

  String get displayName => user != null ? user!.displayName : '';

  String? get avatar => user!.avatar;
}
