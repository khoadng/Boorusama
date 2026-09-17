// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/errors/types.dart';

final sankakuAppErrorTranslatorProvider = Provider<AppErrorTranslator>(
  (ref) => SankakuAppErrorTranslator(),
);

class SankakuAppErrorTranslator extends DefaultAppErrorTranslator {
  @override
  String translateServerError(BuildContext context, ServerError error) =>
      switch (error.code) {
        'snackbar__anonymous_tags-limit' =>
          context.t.sankaku.errors.anonymous_tag_limit,
        'snackbar__account_regular_tags-limit' =>
          context.t.sankaku.errors.account_tag_limit,
        'snackbar__account_regular_excluded-tags-limit' =>
          context.t.sankaku.errors.exclusion_search_restricted,
        _ => super.translateServerError(context, error),
      };
}
