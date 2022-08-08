// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/boorus/danbooru/infra/apis/api.dart';
import 'package:boorusama/boorus/danbooru/infra/apis/danbooru/danbooru_api.dart';

Dio newDio(String url) => Dio(BaseOptions(baseUrl: url));

class ApiEndpointState extends Equatable {
  const ApiEndpointState({
    required this.booru,
  });

  final Booru booru;

  @override
  List<Object?> get props => [booru];
}

class ApiEndpointCubit extends Cubit<ApiEndpointState> {
  ApiEndpointCubit({
    required Booru initialValue,
    required this.factory,
  }) : super(ApiEndpointState(booru: initialValue));

  final BooruFactory factory;

  void changeApi({
    required bool isSafeMode,
  }) {
    final booru = factory.create(
      isSafeMode: isSafeMode,
    );

    emit(ApiEndpointState(
      booru: booru,
    ));
  }
}

class ApiState extends Equatable {
  const ApiState({
    required this.api,
    required this.dio,
  });
  factory ApiState.initial(Dio dio) => ApiState(
        api: DanbooruApi(dio),
        dio: dio,
      );

  final Api api;
  final Dio dio;

  ApiState copyWith({
    Api? api,
    Dio? dio,
  }) =>
      ApiState(
        api: api ?? this.api,
        dio: dio ?? this.dio,
      );

  @override
  List<Object?> get props => [api];
}

class ApiCubit extends Cubit<ApiState> {
  ApiCubit({
    required String defaultUrl,
  }) : super(ApiState.initial(newDio(defaultUrl)));

  void changeApi(Booru booru) {
    final dio = newDio(booru.url);
    emit(state.copyWith(
      api: DanbooruApi(dio),
      dio: dio,
    ));
  }
}
