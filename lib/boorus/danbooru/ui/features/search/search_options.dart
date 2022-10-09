// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/infra/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/warning_container.dart';
import 'package:boorusama/core/utils.dart';
import 'search_history.dart';

class SearchOptions extends StatefulWidget {
  const SearchOptions({
    Key? key,
    required this.config,
    this.onOptionTap,
    this.onHistoryTap,
    required this.metatags,
  }) : super(key: key);

  final ValueChanged<String>? onOptionTap;
  final ValueChanged<String>? onHistoryTap;

  final IConfig config;
  final List<Metatag> metatags;

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );

  bool editMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'search.search_options'.tr().toUpperCase(),
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (!editMode)
                          IconButton(
                            splashRadius: 18,
                            onPressed: () => setState(() => editMode = true),
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                            ),
                          )
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        launchExternalUrl(
                          Uri.parse(widget.config.cheatSheetUrl),
                          mode: LaunchMode.platformDefault,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.circleQuestion,
                        size: 18,
                      ),
                    )
                  ],
                ),
              ),
              Wrap(
                spacing: 4,
                children: [
                  ...context
                      .read<UserMetatagRepository>()
                      .getAll()
                      .map((tag) => GestureDetector(
                            onTap: editMode
                                ? null
                                : () => widget.onOptionTap?.call(tag),
                            child: Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              onDeleted: editMode
                                  ? () async {
                                      await context
                                          .read<UserMetatagRepository>()
                                          .delete(tag);
                                      setState(() => {});
                                    }
                                  : null,
                            ),
                          ))
                      .toList(),
                  if (editMode)
                    IconButton(
                      iconSize: 28,
                      splashRadius: 20,
                      onPressed: () {
                        showAdaptiveBottomSheet(context,
                            builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Metatags'),
                                    automaticallyImplyLeading: false,
                                    actions: [
                                      IconButton(
                                        onPressed: Navigator.of(context).pop,
                                        icon: const Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                  body: Column(
                                    children: [
                                      InfoContainer(
                                          contentBuilder: (context) => const Text(
                                              "Free metatags won't count against the tag limit")),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: widget.metatags.length,
                                          itemBuilder: (context, index) {
                                            final tag = widget.metatags[index];
                                            return ListTile(
                                              onTap: () => setState(() {
                                                Navigator.of(context).pop();
                                                context
                                                    .read<
                                                        UserMetatagRepository>()
                                                    .put(tag.name);
                                              }),
                                              title: Text(tag.name),
                                              trailing: tag.isFree
                                                  ? const Chip(
                                                      label: Text('Free'))
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                      },
                      icon: const Icon(Icons.add),
                    )
                ],
              ),
              if (editMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () => setState(() {
                              editMode = false;
                            }),
                        child: const Text('Done')),
                  ],
                ),
              SearchHistorySection(
                onHistoryTap: (history) => widget.onHistoryTap?.call(history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
