import 'dart:ffi';

String? currentLinuxArchitecture() {
  final abi = Abi.current().toString().split('.').last;
  return switch (abi) {
    'linuxArm' => 'arm',
    'linuxArm64' => 'arm64',
    'linuxIA32' => 'ia32',
    'linuxRiscv32' => 'riscv32',
    'linuxRiscv64' => 'riscv64',
    'linuxX64' => 'x64',
    _ => null,
  };
}
