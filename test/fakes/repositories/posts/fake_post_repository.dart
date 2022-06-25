// // Package imports:
// import 'package:dio/src/cancel_token.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// // Project imports:
// import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

// final fakePostProvider = Provider<IPostRepository>((ref) {
//   return FakePostRepository();
// });

// class FakePostRepository implements IPostRepository {
//   @override
//   Future<List<Post>> getCuratedPosts(
//       DateTime date, int page, TimeScale scale) async {
//     await Future.delayed(const Duration(milliseconds: 10));
//     return List.generate(100, (index) => Post.empty());
//   }

//   @override
//   Future<List<Post>> getMostViewedPosts(DateTime date) async {
//     await Future.delayed(const Duration(milliseconds: 10));
//     return List.generate(100, (index) => Post.empty());
//   }

//   @override
//   Future<List<Post>> getPopularPosts(
//       DateTime date, int page, TimeScale scale) async {
//     await Future.delayed(const Duration(milliseconds: 10));
//     return List.generate(100, (index) => Post.empty());
//   }

//   @override
//   Future<List<Post>> getPosts(String tags, int page,
//       {int limit = 100,
//       CancelToken? cancelToken,
//       bool skipFavoriteCheck = false}) async {
//     await Future.delayed(const Duration(milliseconds: 10));
//     return List.generate(100, (index) => Post.empty());
//   }
// }
