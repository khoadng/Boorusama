// Project imports:
import 'package:boorusama/core/domain/error.dart';

String translateBooruError(BooruError error) => switch (error) {
      AppError e => switch (e.type) {
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
      ServerError e => switch (e.httpStatusCode) {
          422 => 'search.errors.tag_limit',
          500 => 'search.errors.database_timeout',
          429 => 'search.errors.rate_limited',
          410 => 'search.errors.pagination_limit',
          403 => 'search.errors.access_denied',
          401 => 'search.errors.forbidden',
          _ => 'generic.errors.unknown',
        },
      UnknownError e => e.error.toString(),
    };
