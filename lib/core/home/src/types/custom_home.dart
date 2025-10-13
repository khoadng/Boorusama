// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../bookmarks/widgets.dart';
import '../../../boorus/engine/engine.dart';
import '../../../bulk_downloads/widgets.dart';
import '../../../configs/manage/providers.dart';
import '../../../premiums/providers.dart';
import '../../../search/search/routes.dart';

const _kDefaultView = 'default';

final customHomeViewKeyProvider = Provider<CustomHomeViewKey?>((ref) {
  final hasPremium = ref.watch(hasPremiumProvider);

  if (!hasPremium) return null;

  final viewKey = ref.watch(
    currentReadOnlyBooruConfigLayoutProvider.select((value) => value?.home),
  );

  return viewKey;
});

class CustomHomeViewKey extends Equatable {
  const CustomHomeViewKey(
    this.name,
  );

  const CustomHomeViewKey.defaultValue() : name = _kDefaultView;

  factory CustomHomeViewKey.fromJson(dynamic json) {
    final name = json['name'] as String?;

    if (name == null) {
      return const CustomHomeViewKey.defaultValue();
    }

    return CustomHomeViewKey(name);
  }

  final String name;

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {
    'name': name,
  };

  @override
  List<Object?> get props => [name];
}

extension CustomViewKeyX on CustomHomeViewKey {
  bool get isDefault => this == const CustomHomeViewKey.defaultValue();
  bool get isAlt => !isDefault;
}

class CustomHomeDataBuilder extends Equatable {
  const CustomHomeDataBuilder({
    required this.displayName,
    required this.builder,
  });

  final String Function(BuildContext context) displayName;
  final Widget Function(BuildContext context, BooruBuilder booruBuilder)?
  builder;

  @override
  List<Object?> get props => [
    displayName,
    builder,
  ];
}

final kDefaultAltHomeView = {
  const CustomHomeViewKey.defaultValue(): CustomHomeDataBuilder(
    displayName: (context) => context.t.generic.kDefault,
    builder: null,
  ),
  const CustomHomeViewKey('search'): CustomHomeDataBuilder(
    displayName: (context) => context.t.settings.search.search,
    builder: (context, booruBuilder) =>
        booruBuilder.searchPageBuilder(context, const SearchParams()),
  ),
  const CustomHomeViewKey('bookmark'): CustomHomeDataBuilder(
    displayName: (context) => context.t.sideMenu.your_bookmarks,
    builder: (context, booruBuilder) => const BookmarkPage(),
  ),
  const CustomHomeViewKey('bulk_download'): CustomHomeDataBuilder(
    displayName: (context) => context.t.sideMenu.bulk_download,
    builder: (context, booruBuilder) => const BulkDownloadPage(),
  ),
};
