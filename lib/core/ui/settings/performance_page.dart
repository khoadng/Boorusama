// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/i18n.dart';

class PerformancePage extends ConsumerStatefulWidget {
  const PerformancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends ConsumerState<PerformancePage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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
                      ref.updateSettings(
                          settings.copyWith(postsPerPage: newValue));
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
            Builder(
              builder: (context) {
                final size = ref.watch(cacheSizeProvider);

                return ListTile(
                  title: const Text('settings.performance.cache_size').tr(),
                  subtitle: Text('settings.performance.cache_size_info'
                      .tr()
                      .replaceAll('{0}', filesize(size.size))
                      .replaceAll('{1}', size.fileCount.toString())),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        ref.read(cacheSizeProvider.notifier).clearAppCache(),
                    child: const Text('settings.performance.clear_cache').tr(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
