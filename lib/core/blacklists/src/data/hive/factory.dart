// Project imports:
import '../../types/blacklisted_tag_repository.dart';
import '../../types/global_blacklisted_tag_repository_factory.dart';
import 'tag_repository.dart';

final class HiveGlobalBlacklistedTagRepositoryFactory
    implements GlobalBlacklistedTagRepositoryFactory {
  const HiveGlobalBlacklistedTagRepositoryFactory({required this.path});

  final String path;

  @override
  Future<GlobalBlacklistedTagRepository> create() async {
    final repository = HiveBlacklistedTagRepository();
    await repository.init(path);
    return repository;
  }

  @override
  Future<void> dispose(GlobalBlacklistedTagRepository repository) async {
    if (repository case final HiveBlacklistedTagRepository hiveRepository) {
      await hiveRepository.close();
    }
  }
}
