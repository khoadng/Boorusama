// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/core/ui/settings/appearance_page.dart';
import 'package:boorusama/core/ui/settings/download_page.dart';
import 'package:boorusama/core/ui/settings/general_page.dart';
import 'package:boorusama/core/ui/settings/language_page.dart';
import 'package:boorusama/core/ui/settings/performance_page.dart';
import 'package:boorusama/core/ui/settings/privacy_page.dart';
import 'package:boorusama/core/ui/settings/search_settings_page.dart';
import 'package:boorusama/core/ui/settings/settings_page.dart';
import 'application/tags/tags.dart';
import 'domain/posts/post.dart';
import 'domain/tags/metatag.dart';
import 'infra/app_info_provider.dart';
import 'infra/package_info_provider.dart';
import 'platform.dart';
import 'ui/info_container.dart';
import 'ui/original_image_page.dart';
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
