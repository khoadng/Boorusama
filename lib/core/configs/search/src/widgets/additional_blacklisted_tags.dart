// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/create.dart';
import '../../../create/providers.dart';
import '../pages/blacklist_configs_edit_page.dart';
import '../providers/blacklist_configs_notifier.dart';
import '../types/blacklist_combination_mode.dart';
import '../types/utils.dart';
import 'combination_mode_selector.dart';
import 'tag_list_preview.dart';
import 'tag_search_config_chip.dart';

class AdditionalBlacklistedTags extends ConsumerWidget {
  const AdditionalBlacklistedTags({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final rawTags = queryAsList(
      ref.watch(
        editBooruConfigProvider(
          id,
        ).select((value) => value.blacklistConfigsTyped?.blacklistedTags),
      ),
    );
    final enabled =
        ref.watch(
          editBooruConfigProvider(
            id,
          ).select((value) => value.blacklistConfigsTyped?.enable),
        ) ??
        false;

    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    final colorScheme = Theme.of(context).colorScheme;

    return GrayedOut(
      grayedOut: !enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              _onEdit(context, id);
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TagListPreview(
              header: Text(
                'Blacklist',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rawTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Wrap(
                        runAlignment: WrapAlignment.center,
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ...rawTags.map(
                            (e) => TagSearchConfigChip(tag: e),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'No tags',
                      style: TextStyle(
                        color: colorScheme.outline,
                      ),
                    ),
                  if (rawTags.isEmpty &&
                      selectedMode == BlacklistCombinationMode.replace)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Empty blacklist with replace mode will effectively disable blacklist entirely.',
                        style: TextStyle(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      iconColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.onSurface,
                    ),
                    label: const Text('Edit'),
                    icon: const Icon(
                      FontAwesomeIcons.pen,
                      size: 16,
                    ),
                    onPressed: () {
                      _onEdit(context, id);
                    },
                  ),
                  if (rawTags.isNotEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        iconColor: colorScheme.onSurface,
                        foregroundColor: colorScheme.onSurface,
                      ),
                      label: const Text('Clear'),
                      icon: const Icon(
                        FontAwesomeIcons.xmark,
                        size: 16,
                      ),
                      onPressed: () {
                        ref
                            .read(blacklistConfigsProvider(id).notifier)
                            .clearTags();
                      },
                    ),
                ],
              ),
              const CombinationModeSelector(),
            ],
          ),
        ],
      ),
    );
  }

  void _onEdit(BuildContext context, EditBooruConfigId id) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ProviderScope(
          overrides: [
            editBooruConfigIdProvider.overrideWithValue(id),
          ],
          child: const BlacklistConfigsEditPage(),
        ),
      ),
    );
  }
}
