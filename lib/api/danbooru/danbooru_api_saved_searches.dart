// Package imports:
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiSavedSearches {
  @GET('/saved_searches.json')
  Future<HttpResponse> getSavedSearches(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/saved_searches.json')
  @FormUrlEncoded()
  Future<HttpResponse> postSavedSearch(
    @Body() Map<String, dynamic> map,
  );

  @PATCH('/saved_searches/{id}.json')
  @FormUrlEncoded()
  Future<HttpResponse> patchSavedSearch(
    @Path() int id,
    @Body() Map<String, dynamic> map,
  );

  @DELETE('/saved_searches/{id}.json')
  Future<HttpResponse> deleteSavedSearch(
    @Path() int id,
  );
}
