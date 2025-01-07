// Package imports:
import 'package:equatable/equatable.dart';

class AnalyticsViewInfo extends Equatable {
  const AnalyticsViewInfo({
    required this.aspectRatio,
  });

  AnalyticsViewInfo copyWith({
    double? aspectRatio,
  }) {
    return AnalyticsViewInfo(
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  final double aspectRatio;

  @override
  List<Object> get props => [aspectRatio];
}
