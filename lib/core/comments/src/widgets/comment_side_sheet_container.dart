// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

class CommentSideSheetContainer extends StatelessWidget {
  const CommentSideSheetContainer({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, bool useAppBar) builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
      child: Column(
        children: [
          Container(
            height: kToolbarHeight * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 8),
                Text(
                  'comment.comments',
                  style: Theme.of(context).textTheme.titleLarge,
                ).tr(),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    onTap: Navigator.of(context).pop,
                    child: const Icon(Symbols.close),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: builder(context, false),
          ),
        ],
      ),
    );
  }
}
