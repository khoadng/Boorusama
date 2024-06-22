List<int> getPostsPerPagePossibleValue() =>
    [for (var i = 10; i <= 200; i += 1) i];

List<double> getSlideShowIntervalPossibleValue() => [
      0.1,
      0.25,
      0.5,
      ...[for (var i = 1; i <= 30; i += 1) i.toDouble()],
    ];

List<int> getSwipeAreaPossibleValue() => [for (var i = 5; i <= 100; i += 5) i];
