// Package imports:
import 'package:equatable/equatable.dart';

abstract class ImageSourceComposer<T> {
  ImageSource compose(T post);
}

class ImageSource extends Equatable {
  const ImageSource({
    required this.thumbnail,
    required this.sample,
    required this.original,
  });

  final String thumbnail;
  final String sample;
  final String original;

  @override
  List<Object?> get props => [
        thumbnail,
        sample,
        original,
      ];
}
