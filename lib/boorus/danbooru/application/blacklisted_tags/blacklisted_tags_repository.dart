// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class BlacklistedTagsRepository {
  BlacklistedTagsRepository(
    this.userRepository,
    this.accountRepository,
  );

  final IUserRepository userRepository;
  final IAccountRepository accountRepository;
  List<String>? _cache;

  Future<List<String>> getBlacklistedTags() async {
    final account = await accountRepository.get();
    if (account == Account.empty) return [];
    if (_cache != null) return _cache!;
    // ignore: join_return_with_assignment
    _cache = await userRepository
        .getUserById(account.id)
        .then((value) => value.blacklistedTags);

    return _cache!;
  }

  Future<bool> setBlacklistedTags(
    int userId,
    List<String> tags,
  ) async {
    try {
      await userRepository.setUserBlacklistedTags(
        userId,
        tagsToTagString(tags),
      );
      _cache = tags;
      return true;
    } catch (e) {
      _cache = null;
      return false;
    }
  }
}
