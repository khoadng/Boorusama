// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import 'error.dart';

export 'error.dart';

abstract interface class AppErrorTranslator {
  String translateAppError(BuildContext context, AppError error);
  String translateServerError(BuildContext context, ServerError error);
}

class DefaultAppErrorTranslator implements AppErrorTranslator {
  @override
  String translateAppError(BuildContext context, AppError error) =>
      switch (error.type) {
        AppErrorType.cannotReachServer =>
          'Cannot reach server, please check your connection',
        AppErrorType.failedToParseJSON =>
          'Failed to parse data, please report this issue to the developer',
        AppErrorType.failedToLoadBooruConfig => 'Failed to load booru config',
        AppErrorType.loadDataFromServerFailed =>
          'Failed to load data from server, please try again later',
        AppErrorType.booruConfigNotFound => 'Booru config not found',
        AppErrorType.unknown => context.t.generic.errors.unknown,
      };

  @override
  String translateServerError(BuildContext context, ServerError error) =>
      switch (error.httpStatusCode) {
        401 => context.t.search.errors.forbidden,
        403 => context.t.search.errors.access_denied,
        410 => context.t.search.errors.pagination_limit,
        422 => context.t.search.errors.tag_limit,
        429 => context.t.search.errors.rate_limited,
        500 => context.t.search.errors.database_timeout,
        502 => context.t.search.errors.max_capacity,
        503 => context.t.search.errors.down,
        _ => context.t.generic.errors.unknown,
      };
}
