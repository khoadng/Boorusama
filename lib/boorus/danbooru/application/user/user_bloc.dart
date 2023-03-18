// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/application/common.dart';

class UserState extends Equatable {
  const UserState({
    required this.user,
    required this.status,
    required this.favorites,
    required this.uploads,
  });

  factory UserState.initial() => UserState(
        user: User.placeholder(),
        status: LoadStatus.initial,
        favorites: null,
        uploads: null,
      );

  final User user;
  final List<Post>? favorites;
  final List<Post>? uploads;
  final LoadStatus status;

  UserState copyWith({
    User? user,
    LoadStatus? status,
    List<Post>? Function()? favorites,
    List<Post>? Function()? uploads,
  }) =>
      UserState(
        user: user ?? this.user,
        status: status ?? this.status,
        favorites: favorites != null ? favorites() : this.favorites,
        uploads: uploads != null ? uploads() : this.uploads,
      );

  @override
  List<Object?> get props => [user, status, favorites, uploads];
}

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class UserFetched extends UserEvent {
  const UserFetched({
    required this.uid,
  });

  final int uid;

  @override
  List<Object?> get props => [uid];
}

class _FetchedFavorites extends UserEvent {
  const _FetchedFavorites({
    required this.username,
  });

  final String username;

  @override
  List<Object?> get props => [username];
}

class _FetchedUploads extends UserEvent {
  const _FetchedUploads({
    required this.username,
  });

  final String username;

  @override
  List<Object?> get props => [username];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required UserRepository userRepository,
    required PostRepository postRepository,
  }) : super(UserState.initial()) {
    on<UserFetched>((event, emit) async {
      await tryAsync<User>(
        action: () => userRepository.getUserById(event.uid),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onUnknownFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          add(_FetchedFavorites(username: data.name));

          if (data.uploadCount > 0) {
            add(_FetchedUploads(username: data.name));
          }

          emit(state.copyWith(
            user: data,
            status: LoadStatus.success,
          ));
        },
      );
    });

    on<_FetchedFavorites>((event, emit) async {
      final favs = await postRepository.getPosts(
        'ordfav:${event.username}',
        1,
        limit: 20,
      );

      emit(state.copyWith(favorites: () => favs));
    });

    on<_FetchedUploads>((event, emit) async {
      final ups = await postRepository.getPosts(
        'user:${event.username}',
        1,
        limit: 20,
      );

      emit(state.copyWith(uploads: () => ups));
    });
  }
}
