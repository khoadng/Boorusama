import 'package:args/command_runner.dart';

final class DoctorCommand extends Command<int> {
  @override
  String get name => 'doctor';

  @override
  String get description => 'Check local build tooling. Placeholder for now.';

  @override
  Future<int> run() async {
    print('Doctor checks are not implemented yet.');
    return 0;
  }
}
