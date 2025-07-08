// Flutter imports:
import 'package:flutter/material.dart';

class UserDetailsTabView extends StatelessWidget {
  const UserDetailsTabView({
    required this.sliverInfoOverview,
    this.infoDetails,
    super.key,
    this.uploads,
    this.tagChanges,
  });

  final Widget sliverInfoOverview;
  final Widget? infoDetails;
  final Widget? uploads;
  final Widget? tagChanges;

  @override
  Widget build(BuildContext context) {
    final tabMap = {
      if (infoDetails != null) 'Info': infoDetails!,
      if (uploads != null) 'Uploads': uploads!,
      if (tagChanges != null) 'Changes': tagChanges!,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: CustomScrollView(
        slivers: [
          sliverInfoOverview,
          SliverFillRemaining(
            child: tabMap.isEmpty
                ? const Center(
                    child: Text('No content'),
                  )
                : DefaultTabController(
                    length: tabMap.length,
                    child: Column(
                      children: [
                        TabBar(
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          isScrollable: true,
                          tabs: [
                            for (final tab in tabMap.keys) Tab(text: tab),
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                          height: 0,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              for (final tab in tabMap.values) tab,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class UserOverviewScaffold extends StatelessWidget {
  const UserOverviewScaffold({
    required this.userInfo,
    required this.action,
    super.key,
    this.isSelf = false,
  });

  final bool isSelf;
  final Widget userInfo;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: userInfo,
          ),
          if (isSelf) const SizedBox(height: 12),
          if (isSelf) action,
        ],
      ),
    );
  }
}
