// Project imports:
import 'token.dart';
import 'token_option.dart';
import 'utils.dart';

typedef TokenData = ({
  Token token,
  List<TokenOption> options,
});

List<TokenData> parse(
  TokenizerConfigs configs,
  String format,
) =>
    parseParts(format, configs.tokenRegex)
        .map((part) => _parseSingle(part, configs))
        .where((e) => e.$1 != null)
        .map((e) => (token: e.$1!, options: e.$2))
        .toList();

(Token?, List<TokenOption>) _parseSingle(
  String tokenString,
  TokenizerConfigs configs,
) {
  final parts = splitTokenString(tokenString);
  final token = parseToken(parts[0], configs.tokenDefinitions);
  final tokenOptions = parts.length > 1
      ? parseTokenOptions(parts[1], configs)
      : configs.standaloneTokens.containsKey(parts[0])
          ? parseTokenOptions(configs.standaloneTokens[parts[0]]!, configs)
          : <TokenOption>[];

  return (token, tokenOptions);
}

List<String> splitTokenString(String input) {
  final index = input.indexOf(':');
  return index == -1
      ? [input]
      : [input.substring(0, index), input.substring(index + 1)];
}

Token? parseToken(
  String value,
  Map<String, List<String>> tokenDef,
) =>
    tokenDef.containsKey(value) ? Token(name: value) : null;

List<TokenOption> parseTokenOptions(String value, TokenizerConfigs configs) =>
    value
        .split(',')
        .map((value) => parseTokenOption(value, configs))
        .whereNotNull()
        .toList();

TokenOption? parseTokenOption(String value, TokenizerConfigs configs) =>
    getTokenOptionBuilder(TokenOptionPair.parse(value), configs);

List<String> parseParts(
  String format,
  RegExp regExp,
) =>
    regExp
        .allMatches(format)
        .map((match) => match.group(1))
        .whereNotNull()
        .toList();
