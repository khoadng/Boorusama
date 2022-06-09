// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<E> debounce<E>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).switchMap(mapper);
