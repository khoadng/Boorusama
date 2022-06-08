// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

enum BooruType {
  unknown,
  danbooru,
  safebooru,
}

class Booru extends Equatable {
  const Booru({
    required this.url,
    required this.booruType,
  });

  final String url;
  final BooruType booruType;

  static Booru empty = const Booru(
    url: '',
    booruType: BooruType.unknown,
  );

  @override
  List<Object?> get props => [url, booruType];
}

String getEndpoint(BooruType booru) {
  if (booru == BooruType.danbooru) {
    return "https://danbooru.donmai.us/";
  } else {
    return "https://safebooru.donmai.us/";
  }
}

Booru getBooru(bool isSafeMode) {
  if (isSafeMode) {
    return Booru(
      url: getEndpoint(BooruType.safebooru),
      booruType: BooruType.safebooru,
    );
  } else {
    return Booru(
      url: getEndpoint(BooruType.danbooru),
      booruType: BooruType.danbooru,
    );
  }
}

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
  }) : super(ApiEndpointState(booru: initialValue));

  void changeApi(bool isSafeMode) {
    if (isSafeMode) {
      emit(ApiEndpointState(
        booru: getBooru(isSafeMode),
      ));
    } else {
      emit(ApiEndpointState(
        booru: getBooru(isSafeMode),
      ));
    }
  }
}

class ApiState extends Equatable {
  const ApiState({
    required this.api,
  });

  final IApi api;

  @override
  List<Object?> get props => [api];

  factory ApiState.initial(Dio dio) => ApiState(api: DanbooruApi(dio));
}

class ApiCubit extends Cubit<ApiState> {
  ApiCubit({
    required String defaultUrl,
  }) : super(ApiState.initial(Dio(BaseOptions(baseUrl: defaultUrl))));

  void changeApi(Booru booru) {
    final dio = Dio(BaseOptions(baseUrl: booru.url));
    if (booru.booruType == BooruType.danbooru) {
      emit(ApiState(api: DanbooruApi(dio)));
    } else {
      emit(ApiState(api: DanbooruApi(dio)));
    }
  }
}
