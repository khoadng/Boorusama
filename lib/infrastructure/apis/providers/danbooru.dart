import 'package:http/http.dart' as http;

//TODO: shouldn't expose internal http client
class Danbooru {
  final String url = "danbooru.donmai.us";
  final String username = "khoaharp";
  final String apiKey = "tstJTCP7ghdQ82LNfvuz1fAv";
  final http.Client _httpClient;

  http.Client get client => _httpClient;

  Danbooru(this._httpClient);
}
