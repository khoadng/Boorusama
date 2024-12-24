// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/engine.dart';
import '../../configs/ref.dart';
import '../../configs/routes.dart';
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
    final config = ref.watchConfig;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: DottedBorderButton(
        borderColor: Theme.of(context).colorScheme.hintColor,
        onTap: () {
          goToUpdateBooruConfigPage(
            context,
            config: config,
            initialTab: 'appearance',
          );
        },
        title: 'Customize',
      ),
    );
  }
}

class CustomDetailsChooserPage extends StatefulWidget {
  const CustomDetailsChooserPage({
    required this.availableParts, required this.selectedParts, required this.onDone, super.key,
  });

  final List<DetailsPart> availableParts;
  final List<DetailsPart>? selectedParts;
  final void Function(List<DetailsPart> parts) onDone;

  @override
  State<CustomDetailsChooserPage> createState() =>
      _CustomDetailsChooserPageState();
}

class _CustomDetailsChooserPageState extends State<CustomDetailsChooserPage> {
  late List<DetailsPart> selectedParts =
      widget.selectedParts ?? widget.availableParts;

  void _onAdd(DetailsPart part) {
    setState(() {
      selectedParts = [...selectedParts, part];
    });
  }

  void _onRemove(DetailsPart part) {
    setState(() {
      selectedParts =
          selectedParts.where((element) => element != part).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available widgets'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              '${selectedParts.length}/${widget.availableParts.length} selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            trailing: FilledButton(
              onPressed: selectedParts.isNotEmpty
                  ? () {
                      widget.onDone(selectedParts);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Apply'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableParts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.availableParts[index].name),
                  leading: Checkbox(
                    value: selectedParts.contains(widget.availableParts[index]),
                    onChanged: (value) {
                      if (value == true) {
                        _onAdd(widget.availableParts[index]);
                      } else {
                        _onRemove(widget.availableParts[index]);
                      }
                    },
                  ),
                  onTap: () {
                    if (selectedParts.contains(widget.availableParts[index])) {
                      _onRemove(widget.availableParts[index]);
                    } else {
                      _onAdd(widget.availableParts[index]);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
