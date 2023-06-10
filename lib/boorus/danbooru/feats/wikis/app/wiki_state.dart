// Project imports:
import 'package:boorusama/boorus/danbooru/feats/wikis/wikis.dart';

sealed class WikiState {
  const WikiState();
}

class WikiStateLoading extends WikiState {
  const WikiStateLoading();
}

class WikiStateLoaded extends WikiState {
  final Wiki wiki;

  const WikiStateLoaded(this.wiki);
}

class WikiStateError extends WikiState {
  final String message;

  const WikiStateError(this.message);
}

class WikiStateNotFound extends WikiState {
  const WikiStateNotFound();
}
