List<int> getPostsPerPagePossibleValue() =>
    [for (var i = 10; i <= 200; i += 1) i];

List<double> getSlideShowIntervalPossibleValue() =>
    [for (var i = 1; i <= 90; i += 1) i.toDouble()];

List<int> getSwipeAreaPossibleValue() => [for (var i = 5; i <= 100; i += 5) i];
