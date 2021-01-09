import 'package:boorusama/application/authentication/services/i_scrapper_service.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ScrapperService implements IScrapperService {
  final String _url;
  Dio _client;

  ScrapperService(this._url) {
    final cookieJar = CookieJar();
    _client = Dio()..options.baseUrl = _url;
    _client.interceptors.add(CookieManager(cookieJar));
  }

  @override
  Future<Account> crawlAccountData(String username, String password) async {
    //TODO: handle http error i.e 502
    final loginResponse = await _client.get("$_url/login");
    final loginHtml = loginResponse.data.toString();
    final loginDocument = html.parse(loginHtml);

    print("Get login token");
    final authenticityToken = loginDocument.documentElement
        .querySelector("meta[name='csrf-token']")
        .attributes["content"];

    final content = {
      "authenticity_token": authenticityToken,
      "session[url]": "",
      "session[name]": username,
      "session[password]": password,
      "commit": "Login",
    };

    try {
      print("Post login forms");
      await _client.post(
        "$_url/session",
        data: content,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        throw InvalidUsernameOrPassword();
      }
    }

    print("Get to user profile");
    final profileResponse = await _client.get("$_url/profile");
    final profileHtml = profileResponse.data.toString();
    final profileDocument = html.parse(profileHtml);

    final userId = profileDocument.documentElement
        .querySelector("body")
        .attributes["data-current-user-id"];

    print("Get to user api key view");
    final apiKeyViewResponse = await _client.get("$_url/users/$userId/api_key");
    final apiKeyViewHtml = apiKeyViewResponse.data.toString();
    final apiKeyViewDocument = html.parse(apiKeyViewHtml);

    final apiKeyViewAuthenticityToken = apiKeyViewDocument.documentElement
        .querySelector("meta[name='csrf-token']")
        .attributes["content"];

    final apiKeyViewContent = {
      "authenticity_token": apiKeyViewAuthenticityToken,
      "user[password]": password,
      "commit": "Submit",
    };

    print("Get to user api key page");
    final apiKeyResponse = await _client.post(
      "$_url/users/$userId/api_key/view",
      data: apiKeyViewContent,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status < 500,
      ),
    );
    final apiKeyHtml = apiKeyResponse.data.toString();
    final apiKeyDocument = html.parse(apiKeyHtml);
    final apiKey = apiKeyDocument.documentElement
        .querySelector("td[id='api-key']")
        .querySelector("code")
        .innerHtml;

    print("Done scrapping");
    return Account.create(username, apiKey, int.parse(userId));
  }
}

class InvalidUsernameOrPassword implements Exception {}
