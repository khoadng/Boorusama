// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPlaceholder extends StatelessWidget {
  const CarouselPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 20,
      itemBuilder: (context, index, realIndex) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 1.5,
        viewportFraction: 0.5,
        enlargeCenterPage: true,
      ),
    );
  }
}
