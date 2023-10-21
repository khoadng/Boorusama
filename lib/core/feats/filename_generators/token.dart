import 'package:equatable/equatable.dart';

class TokenizerConfigs {
  TokenizerConfigs({
    required this.tokenDefinitions,
    required this.standaloneTokens,
    required this.globalOptionToken,
    required this.tokenRegex,
  });

  factory TokenizerConfigs.defaultConfigs() {
    final tagTokenOptions = [
      'maxlength',
      'unsafe',
      'sort',
      'case',
      'limit',
      'delimiter',
      'include_namespace',
    ];

    return TokenizerConfigs(
      tokenDefinitions: {
        'md5': [
          'maxlength',
        ],
        'extension': [],
        'tags': [
          ...tagTokenOptions,
          'nomod',
        ],
        'artist': [
          ...tagTokenOptions,
          'nomod',
        ],
        'character': [
          ...tagTokenOptions,
          'nomod',
        ],
        'copyright': [
          ...tagTokenOptions,
          'nomod',
        ],
        'general': [
          ...tagTokenOptions,
        ],
        'id': [],
        'source': [
          'urlencode',
        ],
        'rating': [
          'single_letter',
        ],
        'date': [
          'format',
        ],
        'index': [
          'unique_counter',
          'pad_left',
        ]
      },
      standaloneTokens: {
        'date': 'format=dd-MM-yyyy hh.mm',
        'source': 'urlencode',
        'index': 'unique_counter',
      },
      globalOptionToken: 'unsafe=false',
      tokenRegex: RegExp(r'\{([^}]+)\}'),
    );
  }

  final Map<String, List<String>> tokenDefinitions;
  final Map<String, String> standaloneTokens;
  final String globalOptionToken;
  final RegExp tokenRegex;
}

class Token extends Equatable {
  const Token({
    required this.name,
  });

  const Token.empty() : name = '';

  final String name;

  @override
  List<Object?> get props => [name];
}
