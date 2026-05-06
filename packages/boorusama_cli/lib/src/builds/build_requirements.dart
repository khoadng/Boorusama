import '../io/platform.dart';
import '../tool/tool_command.dart';
import '../tool/toolchain.dart';
import 'build_target.dart';

final class BuildRequirements {
  const BuildRequirements._();

  static HostPlatform? requiredHost(BuildTarget target) => switch (target) {
    BuildTarget.ipa || BuildTarget.dmg => HostPlatform.macos,
    BuildTarget.windows => HostPlatform.windows,
    BuildTarget.linux ||
    BuildTarget.appimage ||
    BuildTarget.flatpak => HostPlatform.linux,
    BuildTarget.apk || BuildTarget.aab || BuildTarget.web => null,
  };

  static List<ToolCommand> requiredTools(
    BuildTarget target,
    Toolchain toolchain,
  ) {
    return switch (target) {
      BuildTarget.web || BuildTarget.windows => [toolchain.zip],
      BuildTarget.ipa => [toolchain.pod, toolchain.zip],
      BuildTarget.linux => [toolchain.tar],
      BuildTarget.appimage => const [],
      BuildTarget.flatpak => [toolchain.flatpak, toolchain.flatpakBuilder],
      BuildTarget.dmg => [toolchain.pod, toolchain.createDmg],
      BuildTarget.apk || BuildTarget.aab => const [],
    };
  }

  static List<EnvRequirement> requiredEnv({
    required BuildTarget target,
    required String? flavor,
    required bool foss,
  }) {
    if (foss || flavor != 'prod') return const [];

    if (target == BuildTarget.apk || target == BuildTarget.aab) {
      return const [EnvRequirement('REVENUECAT_GOOGLE_API_KEY')];
    }

    if (target == BuildTarget.ipa) {
      return const [EnvRequirement('REVENUECAT_APPLE_API_KEY')];
    }

    return const [];
  }
}

final class EnvRequirement {
  const EnvRequirement(this.key);

  final String key;
}
