part of 'token_option.dart';

sealed class TokenOption extends Equatable {
  const TokenOption({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];
}

sealed class BooleanTokenOption extends TokenOption with TokenValue<bool> {
  BooleanTokenOption({
    required super.name,
    String? value,
  }) : value = value?.toBool() ?? true;

  @override
  final bool value;

  @override
  List<Object?> get props => [name, value];
}

sealed class IntegerTokenOption extends TokenOption with TokenValue<int> {
  IntegerTokenOption({
    required super.name,
    String? value,
  }) : value = value?.toInt() ?? 0;

  @override
  final int value;

  @override
  List<Object?> get props => [name, value];
}

sealed class StringTokenOption extends TokenOption with TokenValue<String> {
  StringTokenOption({
    required super.name,
    String? value,
  }) : value = value ?? '';

  @override
  final String value;

  @override
  List<Object?> get props => [name, value];
}

final class TokenOptionPair extends Equatable {
  const TokenOptionPair({
    required this.key,
    required this.value,
    required this.attribute,
  });

  factory TokenOptionPair.parse(String data) {
    final split = _splitString(data);

    return switch (split.length) {
      1 => TokenOptionPair(
          key: split[0]!,
          value: null,
          attribute: null,
        ),
      2 => TokenOptionPair(
          key: split[0]!,
          value: split[1],
          attribute: null,
        ),
      3 => TokenOptionPair(
          key: split[0]!,
          attribute: split[1],
          value: split[2],
        ),
      _ => const TokenOptionPair(
          key: '',
          value: null,
          attribute: null,
        ),
    };
  }

  final String key;
  final String? value;
  final String? attribute;

  @override
  List<Object?> get props => [key, value, attribute];
}

List<String?> _splitString(String input) {
  final result = <String>[];
  final bracketIndex = input.indexOf('[');

  if (bracketIndex != -1) {
    // if there is '[', split it by '[' and ']'
    final key = input.substring(0, bracketIndex);
    final rest = input.substring(bracketIndex + 1);
    final endIndex = rest.indexOf(']=');
    if (endIndex != -1) {
      final subKey = rest.substring(0, endIndex);
      final value = rest.substring(endIndex + 2); // skip ']='
      result.addAll([key, subKey, value]);
    }
  } else {
    // if there is no '[', split it by '='
    final int equalsIndex = input.indexOf('=');
    if (equalsIndex != -1) {
      final String key = input.substring(0, equalsIndex);
      final String value = input.substring(equalsIndex + 1);
      result.addAll([key, value]);
    } else {
      // if there is no '=', just add the input
      result.add(input);
    }
  }

  return result;
}

class TokenContext extends Equatable {
  const TokenContext({
    required this.token,
    required this.config,
    required this.options,
  });

  final Token token;
  final List<TokenOption> options;
  final TokenizerConfigs config;

  @override
  List<Object?> get props => [token, options, config];
}

mixin TokenValue<T> {
  T get value;
}

extension TokenOptionX on String {
  int toInt() => int.tryParse(this) ?? 0;
  bool toBool() => toLowerCase() == 'true';
}
