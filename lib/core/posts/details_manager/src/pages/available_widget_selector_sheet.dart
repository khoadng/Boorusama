// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../providers/details_layout_provider.dart';

class AvailableWidgetSelectorSheet extends ConsumerWidget {
  const AvailableWidgetSelectorSheet({
    required this.params,
    required this.controller,
    super.key,
  });

  final DetailsLayoutManagerParams params;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableParts = ref.watch(
      detailsLayoutProvider(params).select((value) => value.selectableParts),
    );

    final notifer = ref.watch(detailsLayoutProvider(params).notifier);

    return Scaffold(
      body: availableParts.isEmpty
          ? Center(
              child: Text('No available widgets, all are selected'.hc),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),
                  child: Text(
                    'Available widgets'.hc,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: availableParts
                        .map(
                          (e) => ListTile(
                            title: Text(e.name),
                            onTap: () {
                              notifer.add(e);
                              Navigator.of(context).pop(e);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
