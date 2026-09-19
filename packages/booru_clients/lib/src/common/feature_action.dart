import 'package:equatable/equatable.dart';

enum ActionRequestMethod {
  get('get'),
  post('post');

  const ActionRequestMethod(this.name);

  final String name;
}

enum ActionAuthMode {
  none('none'),
  sessionCookie('session-cookie');

  const ActionAuthMode(this.name);

  final String name;
}

enum ActionResponseType {
  empty('empty'),
  integer('integer'),
  text('text'),
  json('json');

  const ActionResponseType(this.name);

  final String name;
}

final class FeatureActionEndpoint extends Equatable {
  FeatureActionEndpoint({
    required this.name,
    required this.method,
    required this.path,
    required this.auth,
    required this.responseType,
    this.baseUrl,
    Map<String, String> fixedParams = const {},
    Map<String, String> paramMappings = const {},
  }) : fixedParams = Map.unmodifiable(fixedParams),
       paramMappings = Map.unmodifiable(paramMappings);

  final String name;
  final ActionRequestMethod method;
  final String path;
  final ActionAuthMode auth;
  final ActionResponseType responseType;
  final String? baseUrl;
  final Map<String, String> fixedParams;
  final Map<String, String> paramMappings;

  @override
  List<Object?> get props => [
    name,
    method,
    path,
    auth,
    responseType,
    baseUrl,
    fixedParams,
    paramMappings,
  ];
}
