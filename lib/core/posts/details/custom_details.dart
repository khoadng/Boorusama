// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/engine.dart';
import '../../configs/src/create/appearance_details.dart';
import '../../theme.dart';
import '../../widgets/dotted_border.dart';

const _kDefaultView = 'default';

class CustomDetailsPartKey extends Equatable {
  const CustomDetailsPartKey(
    this.name,
  );

  const CustomDetailsPartKey.defaultValue() : name = _kDefaultView;

  factory CustomDetailsPartKey.fromJson(dynamic json) {
    final name = json['name'] as String?;

    if (name == null) {
      return const CustomDetailsPartKey.defaultValue();
    }

    return CustomDetailsPartKey(name);
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

DetailsPart? parseDetailsPart(String part) {
  if (_knownPartsMap.containsKey(part)) {
    return _knownPartsMap[part];
  }

  return null;
}

List<CustomDetailsPartKey> convertDetailsParts(List<DetailsPart> parts) {
  return parts.map(convertDetailsPart).toList();
}

CustomDetailsPartKey convertDetailsPart(DetailsPart part) {
  return CustomDetailsPartKey(part.name);
}

final _knownPartsMap = {for (final part in DetailsPart.values) part.name: part};

class CustomDetailsDataBuilder extends Equatable {
  const CustomDetailsDataBuilder({
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

class AddCustomDetailsButton extends ConsumerWidget {
  const AddCustomDetailsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: DottedBorderButton(
        borderColor: Theme.of(context).colorScheme.hintColor,
        onTap: () {
          goToQuickEditPostDetailsLayoutPage(
            context,
          );
        },
        title: 'Customize',
      ),
    );
  }
}
