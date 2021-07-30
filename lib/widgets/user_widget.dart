import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:telegram_app/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserWidget extends StatelessWidget {
  final User? user;
  final VoidCallback? onTap;

  const UserWidget(
    this.user, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  factory UserWidget.shimmed() => UserWidget(null);

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          backgroundImage: user != null && user!.avatar != null
              ? CachedNetworkImageProvider(user!.avatar!)
              : null,
          child: Text(user != null && user!.avatar == null ? user!.initials : ''),
        ),
        title: Text(user != null ? user!.displayName : 'First name'),
        subtitle: Text(user != null && user!.lastAccess != null
            ? timeago.format(user!.lastAccess!,
                locale: AppLocalizations.of(context)?.localeName)
            : AppLocalizations.of(context)?.label_last_access ?? ''),
        onTap: onTap,
      );
}
