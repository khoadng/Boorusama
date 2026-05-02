// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/nozomi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/listing/providers.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/search/search/widgets.dart';
import '../posts/providers.dart';
import '../posts/types.dart';

class NozomiSearchPage extends ConsumerStatefulWidget {
  const NozomiSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  ConsumerState<NozomiSearchPage> createState() => _NozomiSearchPageState();
}

class _NozomiSearchPageState extends ConsumerState<NozomiSearchPage> {
  late NozomiPostOrder _order = _parseNozomiPostOrder(widget.params.order);
  ValueNotifier<PostGridController<NozomiPost>?>? _postController;

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(
      nozomiPostRepoWithOrderProvider((config: config, order: _order)),
    );

    return SearchPageScaffold<NozomiPost>(
      params: widget.params,
      fetcher: (page, controller) => postRepo.getPostsFromController(
        controller.tagSet,
        page,
      ),
      landingViewBuilder: (controller) => NozomiSearchLandingView(
        controller: controller,
        order: _order,
        onOrderChanged: _setOrder,
      ),
      searchRegionBuilder: (postController, controller) {
        _postController = postController;

        return DefaultSearchRegion(
          controller: controller,
          initialQuery: widget.params.query,
          postController: postController,
        );
      },
      extraHeaders: (context, postController) => [
        SliverToBoxAdapter(
          child: NozomiSearchOrderHeader(
            order: _order,
            onOrderChanged: _setOrder,
          ),
        ),
      ],
    );
  }

  void _setOrder(
    NozomiPostOrder order, {
    bool refresh = true,
  }) {
    if (_order == order) return;

    setState(() {
      _order = order;
    });

    if (!refresh) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postController?.value?.refresh();
    });
  }
}

class NozomiSearchLandingView extends StatelessWidget {
  const NozomiSearchLandingView({
    required this.controller,
    required this.order,
    required this.onOrderChanged,
    super.key,
  });

  final SearchPageController controller;
  final NozomiPostOrder order;
  final ValueChanged<NozomiPostOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return SearchLandingView(
      child: DefaultSearchLandingChildren(
        children: [
          NozomiSearchOrderSection(
            order: order,
            onOrderChanged: onOrderChanged,
          ),
          DefaultMobileQueryActionSection(controller: controller),
          DefaultMobileFavoriteTagsSection(controller: controller),
          DefaultMobileSearchHistorySection(controller: controller),
        ],
      ),
    );
  }
}

class NozomiSearchOrderHeader extends StatelessWidget {
  const NozomiSearchOrderHeader({
    required this.order,
    required this.onOrderChanged,
    super.key,
  });

  final NozomiPostOrder order;
  final ValueChanged<NozomiPostOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: NozomiSearchOrderControl(
          order: order,
          onOrderChanged: onOrderChanged,
        ),
      ),
    );
  }
}

class NozomiSearchOrderSection extends StatelessWidget {
  const NozomiSearchOrderSection({
    required this.order,
    required this.onOrderChanged,
    super.key,
  });

  final NozomiPostOrder order;
  final ValueChanged<NozomiPostOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'Order',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 12),
          NozomiSearchOrderControl(
            order: order,
            onOrderChanged: onOrderChanged,
          ),
        ],
      ),
    );
  }
}

class NozomiSearchOrderControl extends StatelessWidget {
  const NozomiSearchOrderControl({
    required this.order,
    required this.onOrderChanged,
    super.key,
  });

  final NozomiPostOrder order;
  final ValueChanged<NozomiPostOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<NozomiPostOrder>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment(
          value: NozomiPostOrder.date,
          label: Text('Date'),
        ),
        ButtonSegment(
          value: NozomiPostOrder.popular,
          label: Text('Popular'),
        ),
      ],
      selected: {order},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;

        onOrderChanged(selection.first);
      },
    );
  }
}

NozomiPostOrder _parseNozomiPostOrder(String? value) => switch (value) {
  'popular' => NozomiPostOrder.popular,
  _ => NozomiPostOrder.date,
};
