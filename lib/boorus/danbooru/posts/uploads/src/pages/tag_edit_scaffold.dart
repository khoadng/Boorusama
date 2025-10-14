// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/images/booru_image.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../tags/edit/widgets.dart';

class TagEditUploadScaffold extends ConsumerStatefulWidget {
  const TagEditUploadScaffold({
    required this.contentBuilder,
    required this.aspectRatio,
    required this.imageUrl,
    required this.imageFooterBuilder,
    required this.viewController,
    super.key,
  });

  final Widget Function(double maxHeight) contentBuilder;
  final double aspectRatio;
  final String imageUrl;
  final Widget Function() imageFooterBuilder;
  final TagEditViewController viewController;

  @override
  ConsumerState<TagEditUploadScaffold> createState() =>
      _TagEditUploadScaffoldState();
}

class _TagEditUploadScaffoldState extends ConsumerState<TagEditUploadScaffold> {
  @override
  void initState() {
    super.initState();
    widget.viewController.addListener(_onViewChanged);
  }

  void _onViewChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    widget.viewController.removeListener(_onViewChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symbols.arrow_back),
        ),
      ),
      body: TagEditSplitLayout(
        viewController: widget.viewController,
        imageBuilder: () => _ImageSection(
          imageUrl: widget.imageUrl,
          imageFooterBuilder: widget.imageFooterBuilder,
        ),
        contentBuilder: widget.contentBuilder,
      ),
    );
  }
}

class _ImageSection extends ConsumerWidget {
  const _ImageSection({
    required this.imageUrl,
    required this.imageFooterBuilder,
  });

  final String imageUrl;
  final Widget Function() imageFooterBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight > 80
          ? Column(
              children: [
                Expanded(
                  child: InteractiveViewerExtended(
                    child: BooruImage(
                      config: ref.watchConfigAuth,
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                imageFooterBuilder(),
              ],
            )
          : SizedBox(
              height: constraints.maxHeight - 4,
            ),
    );
  }
}
