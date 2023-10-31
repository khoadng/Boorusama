// Package imports:
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'token.dart';
import 'utils.dart';

part 'token_option_others.dart';
part 'token_option_types.dart';
part 'token_option_bool.dart';
part 'token_option_int.dart';
part 'token_option_string.dart';

typedef TokenOptionHandler = String Function(TokenContext context);

TokenOption getTokenOptionBuilder(
        TokenOptionPair pair, TokenizerConfigs configs) =>
    switch (pair.key) {
      'maxlength' => MaxLengthOption(pair.value),
      'delimiter' => DelimiterOption(pair.value),
      'unsafe' => UnsafeOption(
          pair.value,
          unsafeCharacters: configs.unsafeCharacters,
        ),
      'format' => DateFormatOption(pair.value),
      'single_letter' => RatingSingleLetterOption(pair.value),
      'urlencode' => UrlEncodeOption(pair.value),
      'sort' => SortOption.parse(attribute: pair.attribute, value: pair.value),
      'case' => CaseOption.parse(value: pair.value),
      'nomod' => NoModifiersOption(pair.value),
      'limit' => LimitOption(pair.value),
      'index' => UniqueCounterOption(pair.value),
      'pad_left' => PadLeftOption(pair.value ?? ''),
      'include_namespace' => IncludeNamesOption(pair.value),
      'separator' => FloatingPointSeparator.parse(value: pair.value),
      'precision' => FloatingPointPrecisionOption(pair.value),
      _ => UnknownOption(pair.key, pair.value ?? '')
    };

TokenOptionHandler getTokenOptionHandler(
  String data,
  TokenOption option, {
  Clock? clock,
}) =>
    switch (option) {
      MaxLengthOption o => (context) =>
          data.length > o.value ? data.substring(0, o.value) : data,
      FloatingPointSeparator o => (context) => switch (o.value) {
            FloatingPointSeparatorType.comma => data.replaceAll('.', ','),
            FloatingPointSeparatorType.dot => data.replaceAll(',', '.'),
          },
      FloatingPointPrecisionOption o => (context) => switch (o.value) {
            0 => data.toDoubleCommaAware()?.round().toString() ?? data,
            _ => data.toDoubleCommaAware()?.toStringAsFixed(o.value) ?? data,
          },
      DelimiterOption o => (context) {
          final l = o.value.contains('comma')
              ? o.value.replaceAll('comma', ',')
              : o.value;

          return data.split(' ').join(l);
        },
      UnsafeOption o => (context) => o.value
          ? data
          : data
              .split('')
              .map((e) => o.unsafeCharacters.contains(e) ? '_' : e)
              .join(''),
      DateFormatOption o => (context) =>
          DateFormat(o.value).format(clock?.now() ?? DateTime.now()),
      RatingSingleLetterOption _ => (context) => data.substring(0, 1),
      UrlEncodeOption _ => (context) => Uri.encodeComponent(data),
      CaseOption o => (context) => switch (o.value) {
            StringCase.lower => data.toLowerCase(),
            StringCase.upper => data.toUpperCase(),
            StringCase.upperFirst => data.capitalize(),
            StringCase.none => data,
          },
      SortOption o => (context) => switch ((o.attribute, o.value)) {
            (SortAttribute.name, SortOptionValue.asc) =>
              [...data.split(' ')..sort()].join(' '),
            (SortAttribute.name, SortOptionValue.desc) =>
              [...data.split(' ')..sort((a, b) => b.compareTo(a))].join(' '),
            (SortAttribute.length, SortOptionValue.asc) => [
                ...data.split(' ')..sort((a, b) => a.length.compareTo(b.length))
              ].join(' '),
            (SortAttribute.length, SortOptionValue.desc) => [
                ...data.split(' ')..sort((a, b) => b.length.compareTo(a.length))
              ].join(' '),
            _ => data,
          },
      LimitOption o => (context) => data.split(' ').take(o.value).join(' '),
      NoModifiersOption o => (context) =>
          o.value ? cleanAndRemoveDuplicates(data.split(' ')).join(' ') : data,
      UniqueCounterOption o => (context) => o.value ? data : '',
      PadLeftOption o => (context) => data.padLeft(o.value, '0'),
      IncludeNamesOption o => (context) =>
          o.value ? '${context.token.name}:$data' : data,
      UnknownOption _ => (context) => data,
    };
