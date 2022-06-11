// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';

class BottomLoadingIndicator extends StatelessWidget {
  const BottomLoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => current.status == PostStatus.loading,
        builder: (context, state) {
          return const SliverPadding(
            padding: EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 20, top: 20),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }
}
