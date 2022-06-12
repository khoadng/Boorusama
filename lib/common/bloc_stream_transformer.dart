// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<E> debounce<E>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).switchMap(mapper);

EventTransformer<E> debounceRestartable<E>(
  Duration duration,
) =>
    (events, mapper) =>
        restartable<E>().call(events.debounceTime(duration), mapper);
