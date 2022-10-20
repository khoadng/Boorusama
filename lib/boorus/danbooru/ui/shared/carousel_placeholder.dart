// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/features/explore/explore_carousel.dart';
import 'package:boorusama/core/core.dart';

class CarouselPlaceholder extends StatelessWidget {
  const CarouselPlaceholder({
    Key? key,
    this.child,
  }) : super(key: key);

  factory CarouselPlaceholder.error(BuildContext context) =>
      CarouselPlaceholder(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: Theme.of(context).cardColor,
          ),
          child: const Center(
            child: Icon(Icons.broken_image_outlined),
          ),
        ),
      );

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 20,
      itemBuilder: (context, index, realIndex) {
        return child ??
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: Theme.of(context).cardColor,
              ),
            );
      },
      options: CarouselOptions(
        aspectRatio: 1.5,
        viewportFraction: screenSizeToViewPortFraction(Screen.of(context).size),
        enlargeCenterPage: true,
      ),
    );
  }
}
