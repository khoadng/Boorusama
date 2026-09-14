import 'blacklisted_tag_repository.dart';

abstract interface class GlobalBlacklistedTagRepositoryFactory {
  Future<GlobalBlacklistedTagRepository> create();

  Future<void> dispose(GlobalBlacklistedTagRepository repository);
}
