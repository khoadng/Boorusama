import 'package:boorusama/domain/accounts/account.dart';

abstract class IScrapperService {
  Future<Account> crawlAccountData(String username, String password);
}
