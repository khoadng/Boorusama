// Project imports:
import 'package:boorusama/foundation/error.dart';

String translateBooruError(BooruError error) => switch (error) {
      final AppError e => switch (e.type) {
          AppErrorType.cannotReachServer =>
            'Cannot reach server, please check your connection',
          AppErrorType.failedToParseJSON =>
            'Failed to parse data, please report this issue to the developer',
          AppErrorType.failedToLoadBooruConfig => 'Failed to load booru config',
          AppErrorType.loadDataFromServerFailed =>
            'Failed to load data from server, please try again later',
          AppErrorType.booruConfigNotFound => 'Booru config not found',
          AppErrorType.unknown => 'generic.errors.unknown',
        },
      final ServerError e => switch (e.httpStatusCode) {
          401 => 'search.errors.forbidden',
          403 => 'search.errors.access_denied',
          410 => 'search.errors.pagination_limit',
          422 => 'search.errors.tag_limit',
          429 => 'search.errors.rate_limited',
          500 => 'search.errors.database_timeout',
          502 => 'search.errors.max_capacity',
          503 => 'search.errors.down',
          _ => 'generic.errors.unknown',
        },
      final UnknownError e => e.error.toString(),
    };
