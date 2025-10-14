// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../versions/providers.dart';
import '../../../../versions/types.dart';
import '../../../../versions/widgets.dart';

class UserDetailsTagChanges extends ConsumerStatefulWidget {
  const UserDetailsTagChanges({
    required this.uid,
    super.key,
  });

  final int uid;

  @override
  ConsumerState<UserDetailsTagChanges> createState() =>
      _UserDetailsTagChangesState();
}

class _UserDetailsTagChangesState extends ConsumerState<UserDetailsTagChanges> {
  static const itemsPerPage = 20;
  var currentPage = 1;
  List<DanbooruPostVersion> versions = [];
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPage(currentPage);
  }

  Future<void> _fetchPage(int page) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final config = ref.readConfigAuth;
    final repo = ref.read(danbooruPostVersionsRepoProvider(config));

    try {
      final result = await repo.getPostVersionsFromUpdaterId(
        userId: widget.uid,
        page: page,
        limit: itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        versions = result;
        currentPage = page;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  int? get totalPages => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: PageSelector(
              currentPage: currentPage,
              itemPerPage: itemsPerPage,
              onPageSelect: (page) => _fetchPage(page),
              onNext: () => _fetchPage(currentPage + 1),
              onPrevious: currentPage > 1
                  ? () => _fetchPage(currentPage - 1)
                  : null,
              showLastPage: true,
            ),
          ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                sliver: isLoading
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      )
                    : versions.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No tag changes found'),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => TagEditHistoryCard(
                            version: versions[index],
                            configSearch: ref.watchConfigSearch,
                          ),
                          childCount: versions.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
