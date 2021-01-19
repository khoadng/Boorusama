import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';

abstract class IScrapperService {
  Future<Account> crawlAccountData(String username, String password);
}
