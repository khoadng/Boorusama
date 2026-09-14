// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../foundation/info/app_info.dart';
import '../../../foundation/networking.dart';
import '../../../foundation/url_launcher.dart';
import '../../images/providers.dart';
import '../../posts/sources/types.dart';
import '../../widgets/website_logo.dart';

class DonationPage extends ConsumerWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 32),
              switch (ref.watch(networkStateProvider)) {
                final NetworkConnectedState _ => _buildIconButtons(
                  appInfo,
                  ref,
                ),
                _ => _buildTextButtons(appInfo, ref),
              },
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButtons(AppInfo appInfo, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: appInfo.donationUrls
          .map(
            (url) => TextButton(
              onPressed: () => launchExternalUrlString(
                url,
                launcher: ref.read(externalUrlLauncherProvider),
              ),
              child: Text(url),
            ),
          )
          .toList(),
    );
  }

  Widget _buildIconButtons(AppInfo appInfo, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24,
      children: appInfo.donationUrls
          .map((url) => _DonationIcon(url: url))
          .toList(),
    );
  }
}

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Kurumi.themeOf(context);
    final appInfo = ref.watch(appInfoProvider);

    return Column(
      children: [
        Text(
          'Support ${appInfo.appName}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your support helps keep this app constantly improving',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

final _dioProvider = Provider.autoDispose<Dio>((ref) {
  return Dio();
});

class _DonationIcon extends ConsumerWidget {
  const _DonationIcon({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(_dioProvider);

    return GestureDetector(
      onTap: () => launchExternalUrlString(
        url,
        launcher: ref.read(externalUrlLauncherProvider),
      ),
      child: WebsiteLogo(
        url: getFavicon(_getDonateUrl(url)),
        dio: dio,
        size: 40,
        cacheManager: ref.watch(defaultImageCacheManagerProvider),
      ),
    );
  }

  String _getDonateUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) return '';

    final authority = uri.authority;

    return 'https://$authority';
  }
}
