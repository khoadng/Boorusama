// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:html/parser.dart' as html;
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/core/application/scraper/i_scrapper_service.dart';

final scrapperProvider = Provider<IScrapperService>((ref) {
  final cookieJar = CookieJar();
  final dio = Dio();
  final url = ref.watch(apiEndpointProvider);
  dio.options.baseUrl = url;
  dio.interceptors.add(CookieManager(cookieJar));

  return ScrapperService(
    url: url,
    client: dio,
  );
});

class ScrapperService implements IScrapperService {
  final String url;
  final Dio client;

  ScrapperService({
    @required this.url,
    @required this.client,
  });

  @override
  Future<Account> crawlAccountData(String username, String password) async {
    //TODO: handle http error i.e 502
    final loginResponse = await client.get("$url/login");
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
      await client.post(
        "$url/session",
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
    final profileResponse = await client.get("$url/profile");
    final profileHtml = profileResponse.data.toString();
    final profileDocument = html.parse(profileHtml);

    final userId = profileDocument.documentElement
        .querySelector("body")
        .attributes["data-current-user-id"];

    print("Get to user api key view");
    final apiKeyViewResponse = await client.get("$url/users/$userId/api_key");
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
    final apiKeyResponse = await client.post(
      "$url/users/$userId/api_key/view",
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
