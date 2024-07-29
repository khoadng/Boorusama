// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruSelectorItem extends StatelessWidget {
  const BooruSelectorItem({
    super.key,
    required this.config,
    required this.onTap,
    required this.show,
    required this.selected,
    this.direction = Axis.vertical,
    this.hideLabel = false,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;
  final Axis direction;
  final bool hideLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ConditionalParentWidget(
        condition: hideLabel,
        conditionalBuilder: (child) => Tooltip(
          message: config.name,
          triggerMode: TooltipTriggerMode.manual,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
        child: _build(context),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final logoSize = hideLabel
        ? kPreferredLayout.isMobile
            ? 40.0
            : 36.0
        : null;

    return Container(
      margin: direction == Axis.vertical
          ? EdgeInsets.symmetric(
              vertical: kPreferredLayout.isMobile ? 8 : 4,
            )
          : const EdgeInsets.only(
              bottom: 4,
              left: 4,
            ),
      child: InkWell(
        hoverColor: context.theme.hoverColor.withOpacity(0.1),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onSecondaryTap: () => show(),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (direction == Axis.horizontal)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: selected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: selected
                            ? context.colorScheme.primary
                            : Colors.transparent,
                        width: 48,
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              width: direction == Axis.vertical
                  ? 60
                  : hideLabel
                      ? 52
                      : 72,
              decoration: BoxDecoration(
                border: direction == Axis.vertical
                    ? const Border(
                        left: BorderSide(
                          color: Colors.transparent,
                          width: 4,
                        ),
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (direction == Axis.horizontal)
                    const SizedBox(height: 12)
                  else
                    const SizedBox(height: 4),
                  Container(
                    padding: kPreferredLayout.isDesktop
                        ? EdgeInsets.symmetric(
                            vertical: hideLabel ? 4 : 0,
                          )
                        : null,
                    child: switch (PostSource.from(config.url)) {
                      WebSource source => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BooruLogo(
                            source: source,
                            width: logoSize,
                            height: logoSize,
                          ),
                        ),
                      _ => Card(
                          child: SizedBox(
                            width: logoSize,
                            height: logoSize,
                          ),
                        ),
                    },
                  ),
                  if (direction == Axis.horizontal && hideLabel)
                    const SizedBox(height: 8)
                  else
                    const SizedBox(height: 4),
                  if (!hideLabel)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 4,
                      ),
                      child: Text(
                        config.name,
                        textAlign: TextAlign.center,
                        maxLines: direction == Axis.vertical ? 3 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
