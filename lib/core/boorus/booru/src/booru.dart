// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../http/http.dart';
import 'booru_type.dart';

abstract class Booru extends Equatable {
  const Booru({
    required this.name,
    required this.protocol,
  });

  final String name;
  final NetworkProtocol protocol;

  Iterable<String> get sites;

  BooruType get type;

  int get id => type.id;

  NetworkProtocol? getSiteProtocol(String url) => protocol;

  String getApiUrl(String url) => url;

  String? getLoginUrl() => null;

  bool hasSite(String url) => sites.any((site) => url == site);

  @override
  List<Object?> get props => [name];
}

mixin PassHashAuthMixin {
  String? get loginUrl;
}
