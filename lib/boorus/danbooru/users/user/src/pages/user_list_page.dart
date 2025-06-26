// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../details/routes.dart';
import '../providers/colors.dart';
import '../types/user.dart';

class DanbooruSliverUserListPage extends ConsumerStatefulWidget {
  const DanbooruSliverUserListPage({
    required this.fetchUsers,
    super.key,
  });

  final Future<List<DanbooruUser>> Function(int page) fetchUsers;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruUserListPageState();
}

class _DanbooruUserListPageState
    extends ConsumerState<DanbooruSliverUserListPage> {
  final pagingController = PagingController<int, DanbooruUser>(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(_onPageChanged);
  }

  void _onPageChanged(int pageKey) {
    _fetchPage(pageKey);
  }

  @override
  void dispose() {
    super.dispose();
    pagingController
      ..removePageRequestListener(_onPageChanged)
      ..dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    final users = await widget.fetchUsers(pageKey);
    if (users.isEmpty) {
      pagingController.appendLastPage(users);
    } else {
      final nextPageKey = pageKey + 1;
      pagingController.appendPage(users, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<DanbooruUser>(
        newPageProgressIndicatorBuilder: (context) => _buildLoading(),
        firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
        itemBuilder: (context, user, index) => ListTile(
          title: Text(
            user.name,
            style: TextStyle(
              color: DanbooruUserColor.of(context).fromUser(user),
            ),
          ),
          onTap: () {
            goToUserDetailsPage(
              context,
              uid: user.id,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
