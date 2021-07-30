import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:telegram_app/models/message.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatelessWidget {
  final Message? message;
  final bool sender;
  final GestureTapDownCallback? onTap;

  const MessageWidget(
    this.message, {
    Key? key,
    this.sender = true,
    this.onTap,
  }) : super(key: key);

  factory MessageWidget.shimmed() => MessageWidget(null);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: sender ? Colors.green[50] : null,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message != null && message!.attachmentUrl == null)
                  Text(
                      message != null ? message!.message : 'Lorem ipsum dolor'),
                if (message != null && message!.attachmentUrl != null)
                  CachedNetworkImage(imageUrl: message!.attachmentUrl!),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    message != null
                        ? timeago.format(
                            message!.createdAt,
                            locale: AppLocalizations.of(context)?.localeName,
                          )
                        : 'date',
                    style: Theme.of(context).textTheme.caption,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
