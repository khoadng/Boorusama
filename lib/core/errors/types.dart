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
          '${context.t.search.errors.cannot_reach_server}\n\n${error.message}',
        AppErrorType.handshakeFailed =>
          context.t.search.errors.handshake_failed,
        AppErrorType.loadDataFromServerFailed =>
          context.t.search.errors.failed_to_load_data,
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
        _ => context.t.search.errors.unknown,
      };
}
