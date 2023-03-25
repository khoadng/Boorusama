// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/ui/add_booru_page.dart';
import 'package:boorusama/core/ui/manage_booru_user_page.dart';
import 'application/search_history.dart';
import 'application/tags.dart';
import 'domain/posts/post.dart';
import 'domain/searches.dart';
import 'domain/tags/metatag.dart';
import 'infra/app_info_provider.dart';
import 'infra/package_info_provider.dart';
import 'infra/preloader/preloader.dart';
import 'platform.dart';
import 'ui/booru_image.dart';
import 'ui/image_grid_item.dart';
import 'ui/info_container.dart';
import 'ui/original_image_page.dart';
import 'ui/search/favorite_tags/import_favorite_tag_dialog.dart';
import 'ui/search/full_history_view.dart';
import 'ui/settings/settings.dart';
import 'ui/widgets/parallax_slide_in_page_route.dart';
import 'utils.dart';

void goToOriginalImagePage(BuildContext context, Post post) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    settings: const RouteSettings(
      name: RouterPageConstant.originalImage,
    ),
    child: OriginalImagePage(
      post: post,
      initialOrientation: MediaQuery.of(context).orientation,
    ),
  ));
}

void goToSettingsGeneral(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(ParallaxSlideInPageRoute(
    enterWidget: const GeneralPage(),
    oldWidget: oldWidget,
    settings: const RouteSettings(
      name: RouterPageConstant.settingsGeneral,
    ),
  ));
}

void goToSettingsAppearance(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const AppearancePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsAppearance,
      ),
    ),
  );
}

void goToSettingsLanguage(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const LanguagePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsLanguage,
      ),
    ),
  );
}

void goToSettingsDownload(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const DownloadPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsDownload,
      ),
    ),
  );
}

void goToSettingsPerformance(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const PerformancePage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsPerformance,
      ),
    ),
  );
}

void goToSettingsSearch(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const SearchSettingsPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsSearch,
      ),
    ),
  );
}

void goToSettingsPrivacy(BuildContext context, Widget oldWidget) {
  Navigator.of(context).push(
    ParallaxSlideInPageRoute(
      enterWidget: const PrivacyPage(),
      oldWidget: oldWidget,
      settings: const RouteSettings(
        name: RouterPageConstant.settingsPrivacy,
      ),
    ),
  );
}

void goToChanglog(BuildContext context) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.settingsChangelog,
    ),
    pageBuilder: (context, __, ___) => Scaffold(
      appBar: AppBar(
        title: const Text('settings.changelog').tr(),
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              size: 24,
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('CHANGELOG.md'),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Markdown(
                  data: snapshot.data!,
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
        },
      ),
    ),
  );
}

void goToAppAboutPage(BuildContext context) {
  showAboutDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.settingsInformation,
    ),
    applicationIcon: Image.asset(
      'assets/icon/icon-512x512.png',
      width: 64,
      height: 64,
    ),
    applicationVersion: getVersion(
      context.read<PackageInfoProvider>().getPackageInfo(),
    ),
    applicationLegalese: '\u{a9} 2020-2023 Nguyen Duc Khoa',
    applicationName: context.read<AppInfoProvider>().appInfo.appName,
  );
}

void goToMetatagsPage(
  BuildContext context, {
  required List<Metatag> metatags,
  required void Function(Metatag tag) onSelected,
}) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.metatags,
    ),
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Metatags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          InfoContainer(
            contentBuilder: (context) =>
                const Text('search.metatags_notice').tr(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: metatags.length,
              itemBuilder: (context, index) {
                final tag = metatags[index];

                return ListTile(
                  onTap: () => onSelected(tag),
                  title: Text(tag.name),
                  trailing: tag.isFree ? const Chip(label: Text('Free')) : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Object?> goToFavoriteTagImportPage(
  BuildContext context,
  FavoriteTagBloc bloc,
) {
  return showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.favoriteTagsImport,
    ),
    pageBuilder: (context, _, __) => ImportFavoriteTagsDialog(
      padding: isMobilePlatform() ? 0 : 8,
      onImport: (tagString) => bloc.add(FavoriteTagImported(
        tagString: tagString,
      )),
    ),
  );
}

void goToImagePreviewPage(BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => QuickPreviewImage(
      child: BooruImage(
        placeholderUrl: post.thumbnailImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.sampleImageUrl,
        previewCacheManager: context.read<PreviewImageCacheManager>(),
      ),
    ),
  );
}

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(String history) onTap,
}) {
  final bloc = context.read<SearchHistoryBloc>();

  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: const Duration(milliseconds: 200),
    builder: (_) => BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('search.history.history').tr(),
            actions: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text('Are you sure?').tr(),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onBackground,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('generic.action.cancel').tr(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onClear();
                        },
                        child: const Text('generic.action.ok').tr(),
                      ),
                    ],
                  ),
                ),
                child: const Text('search.history.clear').tr(),
              ),
            ],
          ),
          body: FullHistoryView(
            scrollController: ModalScrollController.of(context),
            onHistoryTap: (value) => onTap(value),
            onHistoryRemoved: (value) => onRemove(value),
            onHistoryFiltered: (value) =>
                bloc.add(SearchHistoryFiltered(value)),
            histories: state.filteredhistories,
          ),
        );
      },
    ),
  );
}

void goToSettingPage(BuildContext context) {
  if (isMobilePlatform()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ));
  } else {
    showDesktopDialogWindow(
      context,
      width: min(MediaQuery.of(context).size.width * 0.8, 900),
      height: min(MediaQuery.of(context).size.height * 0.8, 650),
      builder: (context) => const SettingsPageDesktop(),
    );
  }
}

void goToManageBooruPage(BuildContext context) {
  context.read<ManageBooruUserBloc>().add(const ManageBooruUserFetched());

  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.rightToLeft,
    child: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, state) => const ManageBooruUserPage(),
    ),
  ));
}

void goToAddBooruPage(
  BuildContext context, {
  bool setCurrentBooruOnSubmit = false,
}) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.rightToLeft,
    child: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, state) {
        return AddBooruPage(
          onSubmit: (login, apiKey, booru) => context
              .read<ManageBooruUserBloc>()
              .add(
                ManageBooruUserAdded(
                  login: login,
                  apiKey: apiKey,
                  booru: booru,
                  onSuccess: (userBooru) {
                    if (setCurrentBooruOnSubmit) {
                      context.read<CurrentBooruBloc>().add(CurrentBooruChanged(
                            userBooru: userBooru,
                            settings: state.settings,
                          ));
                    }
                  },
                ),
              ),
        );
      },
    ),
  ));
}

Future<T?> showDesktopDialogWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsets? margin,
  RouteSettings? settings,
}) =>
    showGeneralDialog(
      context: context,
      routeSettings: settings,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: width ?? MediaQuery.of(context).size.width * 0.8,
            height: height ?? MediaQuery.of(context).size.height * 0.8,
            margin: margin ??
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );

Future<T?> showDesktopFullScreenWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) =>
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return builder(context);
      },
    );
