// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/blacklists/blacklisted_tag.dart';
import '../../../../../core/foundation/toast.dart';
import 'blacklisted_tags_notifier.dart';

extension BlacklistedTagsNotifierX on BlacklistedTagsNotifier {
  Future<void> addFromStringWithToast({
    required BuildContext context,
    required String tagString,
  }) async {
    final tags = sanitizeBlacklistTagString(tagString);

    if (tags == null) {
      showErrorToast(
        context,
        'Invalid tag format',
      );
      return;
    }

    await add(
      tagSet: tags.toSet(),
      onSuccess: (tags) =>
          showSuccessToast(context, 'blacklisted_tags.updated'.tr()),
      onFailure: (e) => showErrorToast(
        context,
        '${'blacklisted_tags.failed_to_add'.tr()}\n$e',
      ),
    );
  }

  Future<void> addWithToast({
    required BuildContext context,
    required String tag,
  }) =>
      add(
        tagSet: {tag},
        onSuccess: (tags) => showSuccessToast(
          context,
          'blacklisted_tags.updated'.tr(),
        ),
        onFailure: (e) => showErrorToast(
          context,
          '${'blacklisted_tags.failed_to_add'.tr()}\n$e',
        ),
      );

  Future<void> removeWithToast({
    required BuildContext context,
    required String tag,
  }) =>
      remove(
        tag: tag,
        onSuccess: (tags) => showSuccessToast(
          context,
          'blacklisted_tags.updated'.tr(),
        ),
        onFailure: () => showErrorToast(
          context,
          'blacklisted_tags.failed_to_remove'.tr(),
        ),
      );
}
