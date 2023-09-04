// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiReports {
  @GET('/reports/posts.json')
  Future<HttpResponse> getPostReport(
    @Query('search[tags]') String tags,
    @Query('search[period]') String period,
    @Query('search[from]') String from,
    @Query('search[to]') String to, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
