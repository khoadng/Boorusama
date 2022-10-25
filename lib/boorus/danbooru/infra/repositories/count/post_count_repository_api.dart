// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';

class PostCountRepositoryApi implements PostCountRepository {
  const PostCountRepositoryApi({
    required this.api,
    required this.accountRepository,
  });

  final Api api;
  final AccountRepository accountRepository;

  @override
  Future<int> count(List<String> tags) => accountRepository
      .get()
      .then((account) => api.countPosts(
            account.username,
            account.apiKey,
            tags.join(' '),
          ))
      .then((value) => value.data['counts']['posts']);
}
