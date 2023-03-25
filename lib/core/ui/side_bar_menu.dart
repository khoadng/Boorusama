// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
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
                            trailing: IconButton(
                              onPressed: () => showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    const CurrentBooruActionSheet(),
                              ),
                              icon: const Icon(Icons.more_vert),
                            ),
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
                  icon: const Icon(Icons.manage_accounts),
                  title: const Text('Manage Boorus'),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    goToManageBooruPage(context);
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

// ignore: prefer-single-widget-per-file
class CurrentBooruActionSheet extends StatelessWidget {
  const CurrentBooruActionSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Switch booru'),
            onTap: () {
              Navigator.of(context).pop();
              context
                  .read<ManageBooruUserBloc>()
                  .add(const ManageBooruUserFetched());
              showMaterialModalBottomSheet(
                context: context,
                builder: (_) => const SwitchBooruModal(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class SwitchBooruModal extends StatelessWidget {
  const SwitchBooruModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final users =
        context.select((ManageBooruUserBloc bloc) => bloc.state.users);
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Material(
        color: Colors.transparent,
        child: users != null
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  controller: ModalScrollController.of(context),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      title: Text(
                        BooruType.values[user.booruId].name,
                      ),
                      subtitle: Text(
                        user.login?.isEmpty ?? true
                            ? '<Anonymous>'
                            : user.login ?? 'Unknown',
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        context
                            .read<CurrentBooruBloc>()
                            .add(CurrentBooruChanged(
                              userBooru: user,
                              settings: settings,
                            ));
                      },
                    );
                  },
                ),
              )
            : const SizedBox.shrink(),
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
