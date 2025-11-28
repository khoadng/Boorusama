// Package imports:
import 'package:equatable/equatable.dart';

class PageFinderTarget extends Equatable {
  const PageFinderTarget({
    required this.id,
  });

  final int id;

  @override
  List<Object?> get props => [id];
}
