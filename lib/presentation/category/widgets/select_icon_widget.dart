import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_paisa/presentation/category/bloc/category_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../common/widgets/show_icon_picker.dart';

class SelectIconWidget extends StatelessWidget {
  const SelectIconWidget({
    super.key,
    required this.codePoint,
  });

  final int codePoint;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      buildWhen: (previous, current) => current is CategoryIconSelectedState,
      bloc: BlocProvider.of<CategoryBloc>(context)
        ..add(CategoryIconSelectedEvent(codePoint)),
      builder: (context, state) {
        int codePoint = MdiIcons.home.codePoint;
        if (state is CategoryIconSelectedState) {
          codePoint = state.categoryIcon;
        }
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(AppLocalizations.of(context)!.selectIconLabel),
          subtitle: Text(AppLocalizations.of(context)!.selectIconDescLabel),
          leading: Icon(
            IconData(
              codePoint,
              fontFamily: 'Material Design Icons',
              fontPackage: 'material_design_icons_flutter',
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
          onTap: () async {
            await showIconPicker(
              context: context,
              defaultIcon: IconData(
                codePoint,
                fontFamily: 'Material Design Icons',
                fontPackage: 'material_design_icons_flutter',
              ),
              onSelectedIcon: (iconData) =>
                  BlocProvider.of<CategoryBloc>(context)
                      .add(CategoryIconSelectedEvent(iconData.codePoint)),
            );
          },
        );
      },
    );
  }
}
