// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';

class SearchAppBarResultView extends ConsumerWidget {
  const SearchAppBarResultView({
    super.key,
    required this.onTap,
    required this.onBack,
  });

  final VoidCallback onTap;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight * 1.2,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BooruSearchBar(
          enabled: false,
          onTap: onTap,
          leading: IconButton(
            splashRadius: 16,
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        ),
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }
}
