// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/display.dart';
import '../../../../themes/theme/types.dart';
import '../../../tag/widgets.dart';

class TagOtherNames extends StatelessWidget {
  const TagOtherNames({
    required this.otherNames,
    super.key,
  });

  final List<String>? otherNames;

  @override
  Widget build(BuildContext context) {
    return switch (context.isLargeScreen) {
      false => _buildSmallLayout(),
      true => _buildLargeLayout(),
    };
  }

  Widget _buildSmallLayout() {
    return switch (otherNames) {
      final names? => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: names
                    .map((e) => OtherNameChip(otherName: e))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      null => const TagChipsPlaceholder(height: 42, itemCount: 10),
    };
  }

  Widget _buildLargeLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: switch (otherNames) {
          final names? => Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: names.map((e) => OtherNameChip(otherName: e)).toList(),
          ),
          null => const TagChipsPlaceholder(),
        },
      ),
    );
  }
}

class OtherNameChip extends StatelessWidget {
  const OtherNameChip({
    required this.otherName,
    super.key,
  });

  final String otherName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onLongPress: () {
          AppClipboard.copyWithDefaultToast(
            context,
            otherName,
          );
        },
        child: RawChip(
          onPressed: () {},
          side: BorderSide(
            color: Theme.of(context).colorScheme.hintColor,
            width: 0.5,
          ),
          padding: const EdgeInsets.all(4),
          labelPadding: const EdgeInsets.all(1),
          visualDensity: VisualDensity.compact,
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
            ),
            child: Text(
              otherName.replaceAll('_', ' '),
              overflow: TextOverflow.fade,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
