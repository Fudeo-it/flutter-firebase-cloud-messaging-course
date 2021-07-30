import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:telegram_app/models/model.dart';

part 'message.g.dart';

@CopyWith()
class Message extends Model {
  final String message;
  final String sender;
  final String? attachmentUrl;

  Message({
    String? id,
    required this.message,
    required this.sender,
    this.attachmentUrl,
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
        attachmentUrl,
        message,
        sender,
      ];

  bool isSender(String uid) => sender == uid;
}
