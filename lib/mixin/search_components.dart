import 'package:flutter/material.dart';
import 'package:flutter_essentials_kit/flutter_essentials_kit.dart';
import 'package:telegram_app/cubits/search_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchComponentsMixin {
  Widget searchField(
      BuildContext context,
      ) =>
      TwoWayBindingBuilder<String>(
        binding: context.watch<SearchCubit>().searchBinding,
        builder: (context, controller, data, onChanged, error) => TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            errorText: error?.localizedString(context),
            hintText: AppLocalizations.of(context)?.label_search ?? '',
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
        ),
      );
}