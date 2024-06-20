// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/string.dart';

class UserAgentGeneratorImpl implements UserAgentGenerator {
  UserAgentGeneratorImpl({
    required this.appVersion,
    required this.appName,
    required BooruConfig config,
  }) {
    if (config.booruType == BooruType.zerochan) {
      name = '${appName.sentenceCase}/$appVersion - boorusama';
    } else {
      name = '${appName.sentenceCase}/$appVersion';
    }
  }

  final String appVersion;
  final String appName;
  late final String name;

  @override
  String generate() => name;
}
