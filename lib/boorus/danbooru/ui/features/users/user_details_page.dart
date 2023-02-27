// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_bloc.dart';
import 'package:recase/recase.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserBloc>().state;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text('profile.profile'.tr()),
      ),
      body: SafeArea(
        child: _buildBody(context, user),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserState state) {
    final user = state.user;

    if (state.status == LoadStatus.success) {
      return Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(label: Text(user.level.name.sentenceCase)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(),
            ),
          ],
        ),
      );
    } else if (state.status == LoadStatus.failure) {
      return const Center(
        child: Text('Fail to load profile'),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
