// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/user/user_bloc.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.profile'.tr()),
      ),
      body: SafeArea(
        child: _buildBody(user),
      ),
    );
  }

  Widget _buildBody(UserState state) {
    final user = state.user;

    if (state.status == LoadStatus.success) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  leading: const Text('profile.user_id').tr(),
                  trailing: Text(
                    user.id.toString(),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: const Text('profile.level').tr(),
                  trailing: Text(
                    user.level.name,
                  ),
                ),
              ],
            ),
          ),
        ],
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
