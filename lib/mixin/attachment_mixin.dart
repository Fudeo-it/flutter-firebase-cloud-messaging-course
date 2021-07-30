import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:telegram_app/blocs/image_picker/image_picker_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

class AttachmentMixin {
  Widget bottomSheetPicker(BuildContext context, {required String title, bool picked = false}) {
    final List<dynamic> _actions = [
      if (picked)
        {
          "icon": Icons.delete,
          "color": Colors.red,
          "text": AppLocalizations.of(context)?.action_delete ?? '',
          "action": () => context.read<ImagePickerBloc>().reset(),
        },
      {
        "icon": Icons.camera,
        "color": Colors.orange,
        "text": AppLocalizations.of(context)?.action_camera ?? '',
        "action": () => context.read<ImagePickerBloc>().pickCameraImage(),
      },
      {
        "icon": Icons.photo,
        "color": Colors.blue,
        "text": AppLocalizations.of(context)?.action_gallery ?? '',
        "action": () => context.read<ImagePickerBloc>().pickGalleryImage(),
      },
    ];

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 160,
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _actions.length,
                separatorBuilder: (_, __) => Container(width: 16),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    _actions[index]['action']();

                    context.router.pop();
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Icon(
                          _actions[index]['icon'],
                          color: Colors.white,
                        ),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _actions[index]['color'],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _actions[index]['text'],
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}