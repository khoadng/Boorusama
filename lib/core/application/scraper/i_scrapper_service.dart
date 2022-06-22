// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

abstract class IScrapperService {
  Future<Account> crawlAccountData(String username, String password);
}
