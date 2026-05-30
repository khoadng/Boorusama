import '../builds/build_plan.dart';
import '../project/project.dart';
import 'artifact.dart';

abstract interface class Packager {
  Future<Artifact> package(Project project, BuildPlan plan);
}
