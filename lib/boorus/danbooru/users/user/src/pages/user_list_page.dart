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
  late final pagingController = PagingController(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: _fetchPage,
  );

  @override
  void dispose() {
    pagingController.dispose();

    super.dispose();
  }

  Future<List<DanbooruUser>> _fetchPage(int pageKey) async {
    final users = await widget.fetchUsers(pageKey);
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) => PagedSliverList(
        state: state,
        fetchNextPage: fetchNextPage,
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
                ref,
                uid: user.id,
              );
            },
          ),
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
