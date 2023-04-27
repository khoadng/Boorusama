// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';

class BlacklistState {}

class BlacklistLoading extends BlacklistState {}

class BlacklistLoaded extends BlacklistState {
  final List<BlacklistedTag> tags;

  BlacklistLoaded(this.tags);
}

class BlacklistError extends BlacklistState {}
