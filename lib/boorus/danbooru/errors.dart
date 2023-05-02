// Project imports:
import 'package:boorusama/core/domain/error.dart';

String translateBooruError(BooruError error) =>
    error.mapWhen(
      appError: (appError) =>
          appError.mapWhen(
            cannotReachServer: () =>
                'Cannot reach server, please check your connection',
            failedToParseJSON: () =>
                'Failed to parse data, please report this issue to the developer',
            failedToLoadBooruConfig: () => 'Failed to load booru config',
            loadDataFromServerFailed: () =>
                'Failed to load data from server, please try again later',
            booruConfigNotFound: () => 'Booru config not found',
            unknown: () => 'generic.errors.unknown',
          ) ??
          'generic.errors.unknown',
      serverError: (error) {
        if (error.httpStatusCode == 422) {
          return 'search.errors.tag_limit';
        } else if (error.httpStatusCode == 500) {
          return 'search.errors.database_timeout';
        } else if (error.httpStatusCode == 429) {
          return 'search.errors.rate_limited';
        } else if (error.httpStatusCode == 410) {
          return 'search.errors.pagination_limit';
        } else if (error.httpStatusCode == 403) {
          return 'search.errors.access_denied';
        } else if (error.httpStatusCode == 401) {
          return 'search.errors.forbidden';
        } else if (error.httpStatusCode == 502) {
          return 'search.errors.max_capacity';
        } else if (error.httpStatusCode == 503) {
          return 'search.errors.down';
        } else {
          return 'search.errors.unknown';
        }
      },
      unknownError: (error) {
        return 'generic.errors.unknown';
      },
    ) ??
    'generic.errors.unknown';
