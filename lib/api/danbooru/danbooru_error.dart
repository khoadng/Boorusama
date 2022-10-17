enum DanbooruError {
  badRequest,
  authenticationFailed,
  accessDenied,
  notFound,
  paginationLimit,
  recordCouldNotBeSaved,
  resourceLocked,
  alreadyExists,
  invalidParameters,
  throttled,
  internalErrorOrDatabaseTimeout,
  heavyLoadCannotHandleRequest,
  down,
  unknown,
}

DanbooruError mapHttpStatusCodeToDanbooruError(int? code) {
  if (code == 400) return DanbooruError.badRequest;
  if (code == 401) return DanbooruError.authenticationFailed;
  if (code == 403) return DanbooruError.accessDenied;
  if (code == 404) return DanbooruError.notFound;
  if (code == 410) return DanbooruError.paginationLimit;
  if (code == 420) return DanbooruError.recordCouldNotBeSaved;
  if (code == 422) return DanbooruError.resourceLocked;
  if (code == 423) return DanbooruError.alreadyExists;
  if (code == 424) return DanbooruError.invalidParameters;
  if (code == 429) return DanbooruError.throttled;
  if (code == 500) return DanbooruError.internalErrorOrDatabaseTimeout;
  if (code == 502) return DanbooruError.heavyLoadCannotHandleRequest;
  if (code == 503) return DanbooruError.down;
  return DanbooruError.unknown;
}
