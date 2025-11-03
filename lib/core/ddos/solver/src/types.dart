abstract class HttpResponse {
  int? get statusCode;
  dynamic get data;
  Uri get requestUri;
  Map<String, dynamic> get headers;
}

abstract class HttpError {
  HttpResponse? get response;
  Uri get requestUri;
  String? get message;
}
