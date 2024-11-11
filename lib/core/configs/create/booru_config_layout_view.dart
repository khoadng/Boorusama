// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';

const kDefaultAltHomeView = [
  'default',
  'search',
  'bookmark',
];

final selectedHomeViewProvider = StateProvider<String?>((ref) {
  return 'default';
});

String? defaultDescribeHomeView(String value) => switch (value) {
      'default' => 'Default',
      'search' => 'Search',
      'bookmark' => 'Bookmark',
      _ => null,
    };

class DefaultBooruConfigLayoutView extends StatelessWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BooruConfigLayoutView(
      altHomeView: kDefaultAltHomeView,
      describeHomeView: defaultDescribeHomeView,
    );
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
    required this.altHomeView,
    required this.describeHomeView,
  });

  final List<String> altHomeView;
  final String? Function(String value) describeHomeView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Home screen"),
            subtitle: const Text(
              'Change the view of the home screen',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: ref.watch(selectedHomeViewProvider),
              onChanged: (value) =>
                  ref.read(selectedHomeViewProvider.notifier).state = value,
              items: altHomeView
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describeHomeView(value) ?? 'Default'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
