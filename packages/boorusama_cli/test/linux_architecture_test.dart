import 'package:test/test.dart';

import 'package:boorusama_cli/src/io/linux_architecture.dart';

void main() {
  test('detects Linux ARM64 spellings', () {
    expect(linuxArchitectureFromIdentifiers(['Abi.linuxArm64']), 'arm64');
    expect(linuxArchitectureFromIdentifiers(['linux_arm64']), 'arm64');
    expect(linuxArchitectureFromIdentifiers(['aarch64']), 'arm64');
  });

  test('detects Linux x64 spellings', () {
    expect(linuxArchitectureFromIdentifiers(['Abi.linuxX64']), 'x64');
    expect(linuxArchitectureFromIdentifiers(['x86_64']), 'x64');
    expect(linuxArchitectureFromIdentifiers(['amd64']), 'x64');
  });
}
