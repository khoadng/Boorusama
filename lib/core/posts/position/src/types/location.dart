// Package imports:
import 'package:equatable/equatable.dart';

class PageLocation extends Equatable {
  const PageLocation({
    required this.page,
    required this.index,
  });

  final int page;
  final int index;

  @override
  List<Object> get props => [page, index];
}
