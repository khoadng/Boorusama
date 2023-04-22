// Package imports:
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/domain/user_agent_generator.dart';

class UserAgentGeneratorImpl implements UserAgentGenerator {
  UserAgentGeneratorImpl({
    required this.appVersion,
    required this.appName,
  }) {
    name = '${appName.sentenceCase}/$appVersion';
  }

  final String appVersion;
  final String appName;
  late final String name;

  @override
  String generate() => name;
}
