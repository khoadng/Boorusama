// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'parser.dart';
import 'token_option.dart';

class TokenizerConfigs {
  TokenizerConfigs({
    required this.tokenDefinitions,
    required this.standaloneTokens,
    required this.globalOptionToken,
    required this.tokenRegex,
    this.tokenOptionDocs = const {},
    required this.unsafeCharacters,
    required this.namespacedTokens,
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
      'count',
    ];

    final stringTokenOptions = [
      'maxlength',
      'unsafe',
      'case',
      'urlencode',
    ];

    final floatingPointTokenOptions = [
      'separator',
      'precision',
    ];

    final unsafeCharacters = [
      '/',
      r'\',
      ':',
      '*',
      '?',
      '"',
      '<',
      '>',
      '|',
      ']',
    ];

    return TokenizerConfigs(
      tokenDefinitions: {
        'md5': [
          'maxlength',
          'case',
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
        'meta': [
          ...tagTokenOptions,
        ],
        'species': [
          ...tagTokenOptions,
        ],
        'id': [],
        'width': [],
        'height': [],
        'aspect_ratio': [
          ...floatingPointTokenOptions,
        ],
        'mpixels': [
          ...floatingPointTokenOptions,
        ],
        'source': [
          ...stringTokenOptions,
        ],
        'rating': [
          ...stringTokenOptions,
          'single_letter',
        ],
        'date': [
          'format',
        ],
        'uuid': [
          'uuid:version',
        ],
        'index': [
          '_unique_counter',
          'pad_left',
        ]
      },
      standaloneTokens: {
        'uuid': 'version=4',
        'date': 'format=dd-MM-yyyy hh.mm',
        'source': 'urlencode',
        'index': '_unique_counter',
        'aspect_ratio': 'separator=dot,precision=4',
        'mpixels': 'separator=dot,precision=2',
      },
      globalOptionToken: 'unsafe=false',
      tokenRegex: RegExp(r'\{([^}]+)\}'),
      tokenOptionDocs: {
        'maxlength': 'Limit the maximum length of the token.',
        'unsafe':
            'Whether to allow unsafe characters. The following characters are considered unsafe: ${unsafeCharacters.join()}". They will be replaced with an underscore.',
        'sort':
            'Sort a list of values. Supported attributes are: "name", "length". Available options are: "asc", "desc"\n Example: "sort[name]=asc"',
        'case':
            'Whether to change the case of the token. Available options are: "lower", "upper".',
        'limit':
            'Maximum number of tags to include in the token. If the token is a list of tags, only the first n tags will be included.',
        'delimiter':
            'Delimiter to use when joining the tags. If the token is a list of tags, they will be joined using this delimiter.',
        'include_namespace':
            'Whether to include the namespace of the tags. If the token is a list of tags, the namespace will be included.',
        'nomod':
            'Whether to ignore tag modifiers. For example "tag_(artist)" will become "tag".',
        'urlencode':
            'Whether to encode the token using URL encoding. This is useful when the token is a URL.',
        'single_letter':
            'Whether to use a single letter to represent the token.',
        'format':
            'Format a date using the given format. For example, "dd-MM-yyyy hh.mm".',
        'pad_left': 'Whether to pad the token with zeros.',
        'separator':
            'Floating point separator. Available options are: "comma", "dot".',
        'precision':
            'Floating point precision. For example, "2" will round the number to 2 decimal places.',
        'count':
            'When used, the token will be replaced with the number of values in the list.',
        'uuid:version': 'UUID version. Available options are: "1", "4".',
      },
      unsafeCharacters: unsafeCharacters,
      namespacedTokens: {
        'uuid',
      },
    );
  }

  List<String>? tokenOptionsOf(String token) => tokenDefinitions[token]
      // Ignore internal token options
      ?.where((e) => !e.startsWith('_'))
      .map((e) => namespacedTokens.contains(token) && e.contains(':')
          ? e.substring(e.indexOf(':') + 1)
          : e)
      .toList();

  TokenOptionDocs? tokenOptionDocsOf(String? token, String tokenOption) {
    final desc = tokenOptionDocs[
        token != null && namespacedTokens.contains(token)
            ? '$token:$tokenOption'
            : tokenOption];

    final option = parseTokenOption(tokenOption, token, this);

    return desc != null && option != null
        ? (description: desc, tokenOption: option)
        : null;
  }

  final Map<String, List<String>> tokenDefinitions;
  // For token that can be used without token options
  final Map<String, String> standaloneTokens;
  final Map<String, String> tokenOptionDocs;
  final String globalOptionToken;
  final RegExp tokenRegex;
  final List<String> unsafeCharacters;
  final Set<String> namespacedTokens;
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
