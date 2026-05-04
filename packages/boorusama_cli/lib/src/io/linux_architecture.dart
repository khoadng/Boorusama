import 'dart:ffi';
import 'dart:io';

String? currentLinuxArchitecture() {
  if (!Platform.isLinux) return null;

  return linuxArchitectureFromIdentifiers([
    Abi.current().toString(),
    Platform.version,
    Platform.operatingSystemVersion,
  ]);
}

String? currentAppImageToolArchitecture() {
  return switch (currentLinuxArchitecture()) {
    'arm64' => 'aarch64',
    'x64' => 'x86_64',
    _ => null,
  };
}

String? linuxArchitectureFromIdentifiers(Iterable<String> identifiers) {
  final normalized = identifiers
      .map(
        (identifier) => identifier.toLowerCase().replaceAll(
          RegExp('[^a-z0-9]'),
          '',
        ),
      )
      .join(' ');

  if (normalized.contains('linuxarm64') ||
      normalized.contains('linuxaarch64') ||
      normalized.contains('aarch64')) {
    return 'arm64';
  }
  if (normalized.contains('linuxx64') ||
      normalized.contains('x8664') ||
      normalized.contains('amd64')) {
    return 'x64';
  }
  if (normalized.contains('linuxia32') || normalized.contains('i386')) {
    return 'ia32';
  }
  if (normalized.contains('linuxriscv64')) return 'riscv64';
  if (normalized.contains('linuxriscv32')) return 'riscv32';
  if (normalized.contains('linuxarm')) return 'arm';

  return null;
}
