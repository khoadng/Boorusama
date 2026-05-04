import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/build_requirements.dart';
import 'package:boorusama_cli/src/builds/build_target.dart';
import 'package:boorusama_cli/src/io/platform.dart';
import 'package:boorusama_cli/src/tool/tool_command.dart';
import 'package:boorusama_cli/src/tool/toolchain.dart';

void main() {
  const toolchain = Toolchain(
    flutter: ToolCommand('flutter'),
    dart: ToolCommand('dart'),
    git: ToolCommand('git'),
    pod: ToolCommand('pod'),
    zip: ToolCommand('zip'),
    tar: ToolCommand('tar'),
    appImageTool: ToolCommand('appimagetool'),
    createDmg: ToolCommand('create-dmg'),
  );

  test('web requires zip', () {
    expect(
      BuildRequirements.requiredTools(
        BuildTarget.web,
        toolchain,
      ).map((tool) => tool.displayName),
      ['zip'],
    );
  });

  test('dmg requires macos, CocoaPods, and create-dmg', () {
    expect(BuildRequirements.requiredHost(BuildTarget.dmg), HostPlatform.macos);
    expect(
      BuildRequirements.requiredTools(
        BuildTarget.dmg,
        toolchain,
      ).map((tool) => tool.displayName),
      ['pod', 'create-dmg'],
    );
  });

  test('ipa requires macos, CocoaPods, and zip', () {
    expect(BuildRequirements.requiredHost(BuildTarget.ipa), HostPlatform.macos);
    expect(
      BuildRequirements.requiredTools(
        BuildTarget.ipa,
        toolchain,
      ).map((tool) => tool.displayName),
      ['pod', 'zip'],
    );
  });

  test('appimage requires linux and appimagetool', () {
    expect(
      BuildRequirements.requiredHost(BuildTarget.appimage),
      HostPlatform.linux,
    );
    expect(
      BuildRequirements.requiredTools(
        BuildTarget.appimage,
        toolchain,
      ).map((tool) => tool.displayName),
      ['appimagetool'],
    );
  });

  test('prod android non-foss requires RevenueCat Google key', () {
    final requirements = BuildRequirements.requiredEnv(
      target: BuildTarget.apk,
      flavor: 'prod',
      foss: false,
    );

    expect(requirements.map((requirement) => requirement.key), [
      'REVENUECAT_GOOGLE_API_KEY',
    ]);
  });

  test('foss builds do not require RevenueCat keys', () {
    final requirements = BuildRequirements.requiredEnv(
      target: BuildTarget.apk,
      flavor: 'prod',
      foss: true,
    );

    expect(requirements, isEmpty);
  });
}
