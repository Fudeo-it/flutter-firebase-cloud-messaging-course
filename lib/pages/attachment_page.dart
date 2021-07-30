import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:telegram_app/models/user.dart';

class AttachmentPage extends StatelessWidget {
  final File attachment;
  final User other;
  final void Function(bool) onAttachmentResult;

  const AttachmentPage(
    this.attachment, {
    Key? key,
    required this.other,
    required this.onAttachmentResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _appBar(),
        body: _body(),
        floatingActionButton: _fab(context),
      );

  PreferredSizeWidget _appBar() => AppBar(
        title: Text(other.displayName),
      );

  Widget _body() => Center(child: Image.file(attachment));

  Widget _fab(BuildContext context) => FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          onAttachmentResult(true);

          context.router.pop();
        },
      );
}
