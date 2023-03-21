// // Flutter imports:
// import 'package:flutter/cupertino.dart';

// // Package imports:
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Project imports:
// import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

// @immutable
// class PoolReadState extends Equatable {
//   const PoolReadState({
//     required this.imageUrl,
//     required this.currentIdx,
//     required this.post,
//   });

//   final String imageUrl;
//   final int currentIdx;
//   final Post post;

//   PoolReadState copyWith({
//     String? imageUrl,
//     int? currentIdx,
//     Post? post,
//   }) =>
//       PoolReadState(
//         imageUrl: imageUrl ?? this.imageUrl,
//         currentIdx: currentIdx ?? this.currentIdx,
//         post: post ?? this.post,
//       );

//   @override
//   List<Object?> get props => [imageUrl, currentIdx, post];
// }

// class PoolReadCubit extends Cubit<PoolReadState> {
//   PoolReadCubit({
//     required PoolReadState initialState,
//     required List<Post> posts,
//   })  : _posts = posts,
//         super(initialState);

//   final List<Post> _posts;

//   void next() {
//     final idx = _getNextIndex(_posts, state.currentIdx);

//     emit(state.copyWith(
//       imageUrl: _posts[idx].normalImageUrl,
//       currentIdx: idx,
//       post: _posts[idx],
//     ));
//   }

//   void previous() {
//     final idx = _getPrevIndex(_posts, state.currentIdx);

//     emit(state.copyWith(
//       imageUrl: _posts[idx].normalImageUrl,
//       currentIdx: idx,
//       post: _posts[idx],
//     ));
//   }
// }

// int _getNextIndex<T>(List<T> data, int currentIdx) {
//   final nextIdx = currentIdx + 1;
//   if (nextIdx >= data.length) return 0;
//   return nextIdx;
// }

// int _getPrevIndex<T>(List<T> data, int currentIdx) {
//   final prevIdx = currentIdx - 1;
//   if (prevIdx < 0) return data.length - 1;
//   return prevIdx;
// }
