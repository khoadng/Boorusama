// Package imports:
import 'package:equatable/equatable.dart';

class E621Note extends Equatable {
  const E621Note({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.body,
  });

  final int x;
  final int y;
  final int width;
  final int height;
  final String body;

  @override
  List<Object?> get props => [x, y, width, height, body];
}
