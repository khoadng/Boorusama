// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart';
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
    final loginDocument = await _parseDocument("$url/login");

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
    final profileDocument = await _parseDocument("$url/profile");

    final userId = profileDocument.documentElement
        .querySelector("body")
        .attributes["data-current-user-id"];

    print("Get to user api key view");
    final apiKeyDocument = await _parseDocument("$url/users/$userId/api_keys");

    var apiKeys =
        apiKeyDocument.getElementsByClassName('key-column col-expand');

    if (apiKeys.isEmpty) {
      print("Navigate to api key new");

      final apiKeyNewDocument =
          await _parseDocument("$url/users/$userId/api_keys/new");

      print("Create api key");
      final token = apiKeyNewDocument.documentElement
          .querySelector("meta[name='csrf-token']")
          .attributes["content"];

      final content = {
        "authenticity_token": token,
        "api_key[name]": "boorusama",
        "api_key[permitted_ip_addresses]": '',
        "commit": "Create",
      };

      try {
        await client.post(
          "$url/api_keys",
          data: content,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );
      } on DioError catch (e) {
        if (e.response.statusCode == 302) {
          // Allow redirect
        } else {
          throw InvalidUsernameOrPassword();
        }
      }

      print("Get to user api key view");
      final apiKeyDocument =
          await _parseDocument("$url/users/$userId/api_keys");

      apiKeys = apiKeyDocument.getElementsByClassName('key-column col-expand');
    }

    print("Done scrapping");
    return Account.create(
        username, apiKeys.first.text.trim(), int.parse(userId));
  }

  Future<Document> _parseDocument(String url) async {
    final response = await client.get(url);
    final htmlString = response.data.toString();
    final document = html.parse(htmlString);

    return document;
  }
}

class InvalidUsernameOrPassword implements Exception {}
