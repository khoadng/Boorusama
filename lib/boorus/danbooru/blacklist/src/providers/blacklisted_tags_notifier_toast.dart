// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/blacklists/blacklist.dart';
import '../../../../../foundation/toast.dart';
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
          showSuccessToast(context, context.t.blacklisted_tags.updated),
      onFailure: (e) => showErrorToast(
        context,
        '${context.t.blacklisted_tags.failed_to_add}\n$e',
      ),
    );
  }

  Future<void> addWithToast({
    required BuildContext context,
    required String tag,
  }) => add(
    tagSet: {tag},
    onSuccess: (tags) => showSuccessToast(
      context,
      context.t.blacklisted_tags.updated,
    ),
    onFailure: (e) => showErrorToast(
      context,
      '${context.t.blacklisted_tags.failed_to_add}\n$e',
    ),
  );

  Future<void> removeWithToast({
    required BuildContext context,
    required String tag,
  }) => remove(
    tag: tag,
    onSuccess: (tags) => showSuccessToast(
      context,
      context.t.blacklisted_tags.updated,
    ),
    onFailure: () => showErrorToast(
      context,
      context.t.blacklisted_tags.failed_to_remove,
    ),
  );
}
