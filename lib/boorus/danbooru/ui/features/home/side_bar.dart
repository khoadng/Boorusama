// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/manage_booru_user_page.dart';
import 'package:boorusama/core/ui/side_bar.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;

  @override
  Widget build(BuildContext context) {
    return SideBar(
      width: width,
      content: SingleChildScrollView(
        child: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
                  builder: (context, state) {
                    return state.booru != null
                        ? ListTile(
                            title: Text(state.booru!.name),
                            subtitle: state.userBooru.hasLoginDetails()
                                ? Text(state.userBooru!.login ?? 'Unknown')
                                : const Text('<Anonymous>'),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                if (initialContentBuilder != null) ...[
                  ...initialContentBuilder!(context)!,
                  const Divider(),
                ],
                const Divider(),
                _SideMenuTile(
                  icon: const Icon(Icons.account_box_sharp),
                  title: const Text('Manage Accounts'),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    final bloc = ManageBooruUserBloc(
                      userBooruRepository: context.read<UserBooruRepository>(),
                      booruFactory: context.read<BooruFactory>(),
                      booruUserIdentityProvider:
                          context.read<BooruUserIdentityProvider>(),
                    );
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) =>
                                bloc..add(const ManageBooruUserFetched()),
                          ),
                        ],
                        child: Builder(builder: (context) {
                          return const ManageBooruUserPage();
                        }),
                      ),
                    );
                  },
                ),
                _SideMenuTile(
                  icon: const Icon(Icons.settings_outlined),
                  title: Text('sideMenu.settings'.tr()),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    goToSettingPage(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  const _SideMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Widget icon;
  final Widget title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: ListTile(
          leading: icon,
          title: title,
          onTap: onTap,
        ),
      ),
    );
  }
}
