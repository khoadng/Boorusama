import '../../../http/http.dart';
import 'booru.dart';
import 'booru_type.dart';

abstract class BooruParser {
  BooruType get booruType;
  Booru parse(String name, dynamic data);
}

class BooruDefinition {
  const BooruDefinition({
    required this.name,
    required this.rawConfig,
    required this.type,
  });

  T createStandardBooru<T extends Booru>(
    T Function(String name, NetworkProtocol protocol, List<String> sites)
        constructor,
  ) =>
      constructor(name, getProtocol(), getSites());

  final String name;
  final dynamic rawConfig;
  final BooruType type;

  NetworkProtocol getProtocol() =>
      parseProtocol(rawConfig['protocol'] ?? 'https_2');
  List<String> getSites() => List<String>.from(rawConfig['sites'] ?? []);
  Map<String, dynamic> getHeaders() =>
      Map<String, dynamic>.from(rawConfig['headers'] ?? {});
  String? getLoginUrl() => rawConfig['login-url'];
}

class BooruSiteDefinition {
  const BooruSiteDefinition({
    required this.name,
    required this.protocol,
    required this.sites,
  });

  final String name;
  final NetworkProtocol protocol;
  final List<String> sites;
}

typedef BooruMapper = Booru Function(BooruDefinition definition);

class YamlBooruParser implements BooruParser {
  const YamlBooruParser({
    required BooruType type,
    required BooruMapper mapper,
  })  : _type = type,
        _mapper = mapper;

  factory YamlBooruParser.standard({
    required BooruType type,
    required Booru Function(BooruSiteDefinition siteDef) constructor,
  }) =>
      YamlBooruParser(
        type: type,
        mapper: (def) {
          final siteDef = BooruSiteDefinition(
            name: def.name,
            protocol: def.getProtocol(),
            sites: def.getSites(),
          );
          return constructor(siteDef);
        },
      );

  final BooruType _type;
  final BooruMapper _mapper;

  @override
  BooruType get booruType => _type;

  @override
  Booru parse(String name, dynamic data) {
    final definition = BooruDefinition(
      name: name,
      rawConfig: data,
      type: _type,
    );

    return _mapper(definition);
  }
}
