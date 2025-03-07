// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../blacklists/widgets.dart';
import '../../../widgets/widgets.dart';
import '../../config.dart';
import '../../manage.dart';
import 'providers.dart';
import 'search.dart';

class BlacklistConfigs extends Equatable {
  const BlacklistConfigs({
    required this.combinationMode,
    required this.blacklistedTags,
    required this.enable,
  });

  BlacklistConfigs.defaults()
      : combinationMode = BlacklistCombinationMode.merge.id,
        blacklistedTags = null,
        enable = false;

  factory BlacklistConfigs.fromJson(Map<String, dynamic> json) {
    try {
      return BlacklistConfigs(
        combinationMode: json['combinationMode'] as String,
        blacklistedTags: json['blacklistedTags'] as String?,
        enable: json['enable'] as bool,
      );
    } on Exception catch (_) {
      return BlacklistConfigs.defaults();
    }
  }

  factory BlacklistConfigs.fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => BlacklistConfigs.defaults(),
        final String s => tryDecodeJson(s).fold(
            (_) => BlacklistConfigs.defaults(),
            (json) => BlacklistConfigs.fromJson(json),
          ),
      };

  BlacklistConfigs copyWith({
    String? combinationMode,
    String? blacklistedTags,
    bool? enable,
  }) {
    return BlacklistConfigs(
      combinationMode: combinationMode ?? this.combinationMode,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
      enable: enable ?? this.enable,
    );
  }

  final String combinationMode;
  final String? blacklistedTags;
  final bool enable;

  List<String> get blacklistedTagsList => queryAsList(blacklistedTags).toList();

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'combinationMode': combinationMode,
      'blacklistedTags': blacklistedTags,
      'enable': enable,
    };
  }

  @override
  List<Object?> get props => [combinationMode, blacklistedTags, enable];
}

class BlacklistCombinationMode extends Equatable {
  const BlacklistCombinationMode({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
  });

  factory BlacklistCombinationMode.fromString(String value) {
    return kBlacklistCombinationModes.firstWhere(
      (e) => e.id == value,
      orElse: () => BlacklistCombinationMode.merge,
    );
  }

  static const merge = BlacklistCombinationMode(
    id: 'merge',
    name: 'Merge',
    description: 'Merge this blacklist together with the other blacklists.',
    isDefault: true,
  );

  static const replace = BlacklistCombinationMode(
    id: 'replace',
    name: 'Replace',
    description:
        'Override global blacklist with this blacklist. Useful when you want to have a blacklist that is only used for this profile without affecting the global blacklist.',
  );

  final String id;
  final String name;
  final String description;
  final bool isDefault;

  @override
  List<Object?> get props => [name, description];
}

const kBlacklistCombinationModes = [
  BlacklistCombinationMode.merge,
  BlacklistCombinationMode.replace,
];

class CombinationModeSelector extends ConsumerWidget {
  const CombinationModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          showBooruModalBottomSheet(
            context: context,
            builder: (context) => ProviderScope(
              overrides: [
                editBooruConfigIdProvider.overrideWithValue(id),
              ],
              child: const CombinationModeSheet(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          child: Row(
            children: [
              Text(
                selectedMode.name,
              ),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdditionalBlacklistedTags extends ConsumerWidget {
  const AdditionalBlacklistedTags({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final rawTags = queryAsList(
      ref.watch(
        editBooruConfigProvider(id)
            .select((value) => value.blacklistConfigsTyped?.blacklistedTags),
      ),
    );
    final enabled = ref.watch(
          editBooruConfigProvider(id)
              .select((value) => value.blacklistConfigsTyped?.enable),
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

class CombinationModeSheet extends ConsumerWidget {
  const CombinationModeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Text(
            'Combination Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...kBlacklistCombinationModes.map(
          (e) => CombinationModeOptionTile(
            selected: selectedMode == e,
            title: e.name,
            subtitle: e.description,
            onTap: () {
              ref.read(blacklistConfigsProvider(id).notifier).changeMode(e);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class CombinationModeOptionTile extends StatelessWidget {
  const CombinationModeOptionTile({
    required this.title,
    required this.subtitle,
    super.key,
    this.selected = false,
    this.onTap,
  });

  final bool selected;
  final void Function()? onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.all(12 + (selected ? 0 : 1.5)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(
              width: selected ? 1.5 : 0.25,
              color:
                  selected ? colorScheme.onSurface : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnableAdditionalBlacklistSwitch extends ConsumerWidget {
  const EnableAdditionalBlacklistSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistConfigs = ref.watch(
      blacklistConfigsProvider(ref.watch(editBooruConfigIdProvider)),
    );
    final notifier = ref.watch(
      blacklistConfigsProvider(ref.watch(editBooruConfigIdProvider)).notifier,
    );

    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      title: const Text(
        'Enable profile-specific blacklist',
      ),
      value: blacklistConfigs.enable,
      onChanged: (value) => notifier.changeEnable(value),
    );
  }
}

final blacklistConfigsProvider = NotifierProvider.autoDispose
    .family<BlacklistConfigsNotifier, BlacklistConfigs, EditBooruConfigId>(
  BlacklistConfigsNotifier.new,
);

class BlacklistConfigsNotifier
    extends AutoDisposeFamilyNotifier<BlacklistConfigs, EditBooruConfigId> {
  @override
  BlacklistConfigs build(EditBooruConfigId arg) {
    final editNotifier = ref.watch(editBooruConfigProvider(arg).notifier);

    listenSelf(
      (prev, next) {
        editNotifier.updateBlacklistConfigs(next);
      },
    );

    return ref.watch(
          editBooruConfigProvider(arg)
              .select((value) => value.blacklistConfigsTyped),
        ) ??
        BlacklistConfigs.defaults();
  }

  void changeEnable(bool value) {
    state = state.copyWith(enable: value);
  }

  void changeMode(BlacklistCombinationMode mode) {
    state = state.copyWith(combinationMode: mode.id);
  }

  void addTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.isEmpty ? [tag] : [...currentTags, tag];
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }

  void removeTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.where((e) => e != tag).toList();
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }

  void clearTags() {
    state = state.copyWith(
      blacklistedTags: null,
    );
  }

  void editTag(String oldTag, String newTag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.map((e) => e == oldTag ? newTag : e).toList();
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }
}

class BlacklistConfigsEditPage extends ConsumerWidget {
  const BlacklistConfigsEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final tags = queryAsList(
      ref.watch(
        editBooruConfigProvider(id)
            .select((value) => value.blacklistConfigsTyped?.blacklistedTags),
      ),
    );
    final notifier = ref.watch(blacklistConfigsProvider(id).notifier);

    return BlacklistedTagsViewScaffold(
      tags: tags,
      onRemoveTag: (tag) {
        notifier.removeTag(tag);
      },
      onEditTap: (oldTag, newTag) {
        notifier.editTag(oldTag, newTag);
      },
      onAddTag: (tag) {
        notifier.addTag(tag);
      },
      title: 'Blacklist',
      actions: const [],
    );
  }
}
