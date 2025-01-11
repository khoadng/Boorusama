// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../bookmarks/widgets.dart';
import '../boorus/engine/engine.dart';
import '../downloads/bulks.dart';

const _kDefaultView = 'default';

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

extension CustomViewKeyX on CustomHomeViewKey? {
  bool get isDefault => this == const CustomHomeViewKey.defaultValue();
  bool get isAlt => this != null && !isDefault;
}

class CustomHomeDataBuilder extends Equatable {
  const CustomHomeDataBuilder({
    required this.displayName,
    required this.builder,
  });

  final String displayName;
  final Widget Function(BuildContext context, BooruBuilder booruBuilder)?
      builder;

  @override
  List<Object?> get props => [
        displayName,
        builder,
      ];
}

final kDefaultAltHomeView = {
  const CustomHomeViewKey.defaultValue(): const CustomHomeDataBuilder(
    displayName: 'Default',
    builder: null,
  ),
  const CustomHomeViewKey('search'): CustomHomeDataBuilder(
    displayName: 'settings.search.search',
    builder: (context, booruBuilder) =>
        booruBuilder.searchPageBuilder(context, null),
  ),
  const CustomHomeViewKey('bookmark'): CustomHomeDataBuilder(
    displayName: 'sideMenu.your_bookmarks',
    builder: (context, booruBuilder) => const BookmarkPage(),
  ),
  const CustomHomeViewKey('bulk_download'): CustomHomeDataBuilder(
    displayName: 'sideMenu.bulk_download',
    builder: (context, booruBuilder) => const BulkDownloadPage(),
  ),
};
