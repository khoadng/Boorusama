// Package imports:
import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'parser.dart';
import 'token.dart';
import 'token_option.dart';

String generateFileName(
  Map<String, String?> metadata,
  String format, {
  Clock? clock,
  Uuid uuid = const Uuid(),
  TokenizerConfigs? configs,
}) {
  final cfg = configs ?? TokenizerConfigs.defaultConfigs();
  final tokens = parse(cfg, format);

  // filter null metadata
  final meta = {
    for (final entry in metadata.entries)
      if (entry.value != null) entry.key: entry.value
  };

  final data = tokens
      .map((e) => applyTokenOptions(
            meta[e.token.name] ?? '',
            TokenContext(
              token: e.token,
              config: cfg,
              options: filterDuplicatedOptions([
                ...parseTokenOptions(cfg.globalOptionToken, e.token.name, cfg),
                ...e.options,
              ]),
            ),
            clock: clock,
            uuid: uuid,
          ))
      .toList();

  final fileName = fillArrayInString(cfg.tokenRegex, format, data);

  return fileName;
}

String applyTokenOptions(
  String data,
  TokenContext context, {
  Clock? clock,
  required Uuid uuid,
}) =>
    context.options
        .where((o) =>
            context.config.tokenDefinitions.containsKey(context.token.name) &&
            context.config.tokenDefinitions[context.token.name]!
                .contains(o.name))
        .fold(
          data,
          (data, option) => getTokenOptionHandler(
            data,
            option,
            clock: clock,
            uuid: uuid,
          )(context),
        );

List<TokenOption> filterDuplicatedOptions(List<TokenOption> options) {
  final m = <String, List<int>>{};

  for (var i = 0; i < options.length; i++) {
    final k = options[i].name;
    if (m.containsKey(k)) {
      m[k]!.add(i);
    } else {
      m[k] = [i];
    }
  }

  return m.values.map((e) => options[e.last]).toList();
}

String fillArrayInString(
  RegExp regex,
  String string,
  List<String> array,
) {
  var count = 0;

  return string.replaceAllMapped(
    regex,
    (match) {
      if (count < array.length) {
        final replacement = array[count];
        count++;
        return replacement;
      } else {
        return match.group(0)!;
      }
    },
  );
}
