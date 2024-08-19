// Project imports:
import 'package:boorusama/boorus/danbooru/wikis/wikis.dart';

sealed class WikiState {
  const WikiState();
}

class WikiStateLoading extends WikiState {
  const WikiStateLoading();
}

class WikiStateLoaded extends WikiState {

  const WikiStateLoaded(this.wiki);
  final Wiki wiki;
}

class WikiStateError extends WikiState {

  const WikiStateError(this.message);
  final String message;
}

class WikiStateNotFound extends WikiState {
  const WikiStateNotFound();
}
