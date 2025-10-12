// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class NoteStyle extends Equatable {
  const NoteStyle({
    this.borderColor,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Color? borderColor;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  List<Object?> get props => [
    borderColor,
    backgroundColor,
    foregroundColor,
  ];
}
