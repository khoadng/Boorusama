// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/utils/flutter_utils.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../configs/config/providers.dart';
import '../../../images/booru_image.dart';
import '../../../themes/theme/types.dart';

class DownloadTileBuilder extends StatelessWidget {
  const DownloadTileBuilder({
    required this.url,
    required this.builder,
    super.key,
    this.fileSize,
    this.networkSpeed,
    this.timeRemaining,
    this.thumbnailUrl,
    this.onCancel,
    this.siteUrl,
    this.onLongPress,
    this.onTap,
  });

  final String? thumbnailUrl;
  final int? fileSize;
  final double? networkSpeed; // in MB/s
  final Duration? timeRemaining;
  final String url;
  final Widget Function(String)? builder;
  final void Function()? onCancel;
  final String? siteUrl;
  final void Function()? onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fileSizeText = fileSize != null && fileSize! > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;
    final networkSpeedText = networkSpeed.toOption().fold(
      () => null,
      (s) => switch (s) {
        <= 0 => '-- MB/s',
        >= 1 => '${s.round()} MB/s',
        _ => '${(s * 1000).round()} kB/s',
      },
    );
    final timeRemainingText = timeRemaining.toOption().fold(
      () => null,
      (t) => _durationToTime(t),
    );
    final extensionText = urlExtension(url);

    final infoText = [
      extensionText,
      fileSizeText,
      networkSpeedText,
      timeRemainingText,
    ].nonNulls.join(' • ');

    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: thumbnailUrl.toOption().fold(
                () => SizedBox(
                  height: 60,
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: const Icon(
                      Symbols.image,
                      color: Colors.white,
                    ),
                  ),
                ),
                (t) => _Thumbnail(url: t),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (siteUrl != null && siteUrl!.isNotEmpty)
                        ConfigAwareWebsiteLogo(
                          url: siteUrl,
                          width: 18,
                          height: 18,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            infoText,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (onCancel != null)
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: const ShrinkVisualDensity(),
                          ),
                          onPressed: onCancel,
                          child: Text(context.t.generic.action.cancel),
                        )
                      else
                        const SizedBox(
                          height: 32,
                        ),
                    ],
                  ),
                  builder?.call(url) ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _durationToTime(Duration duration) {
  // 00:00:00 format
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class RawDownloadTile extends StatelessWidget {
  const RawDownloadTile({
    required this.fileName,
    required this.subtitle,
    required this.url,
    required this.trailing,
    super.key,
    this.strikeThrough = false,
    this.color,
  });

  final String fileName;
  final Widget subtitle;
  final String url;
  final Widget trailing;
  final bool strikeThrough;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // don't use ListTile here because our trailing is very custom
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                data: fileName,
                strikeThrough: strikeThrough,
                color: color,
              ),
              subtitle,
            ],
          ),
        ),
        const SizedBox(width: 4),
        trailing,
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.data,
    this.strikeThrough = false,
    this.color,
  });

  final String data;
  final bool strikeThrough;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
        decoration: strikeThrough ? TextDecoration.lineThrough : null,
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.url,
  });

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Consumer(
        builder: (_, ref, _) => BooruImage(
          config: ref.watchConfigAuth,
          imageUrl: url ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
