// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  @override
  Widget build(BuildContext context) {
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.performance.performance').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            ListTile(
              title: const Text('settings.performance.posts_per_page').tr(),
              subtitle:
                  const Text('settings.performance.posts_per_page_explain')
                      .tr(),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  alignment: AlignmentDirectional.centerEnd,
                  isDense: true,
                  value: settings.postsPerPage,
                  focusColor: Colors.transparent,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 5, top: 2),
                    child: FaIcon(FontAwesomeIcons.angleDown, size: 16),
                  ),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      context
                          .read<SettingsCubit>()
                          .update(settings.copyWith(postsPerPage: newValue));
                    }
                  },
                  items: getPostsPerPagePossibleValue()
                      .map<DropdownMenuItem<int>>((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
