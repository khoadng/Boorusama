import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConditionalValueListenableBuilder extends StatelessWidget {
  const ConditionalValueListenableBuilder({
    super.key,
    required this.valueListenable,
    required this.trueChild,
    required this.falseChild,
    this.useFalseChildAsCache = false,
  });
  final ValueListenable<bool> valueListenable;
  final Widget trueChild;
  final Widget falseChild;
  final bool useFalseChildAsCache;

  @override
  Widget build(BuildContext context) {
    if (!useFalseChildAsCache) {
      return ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, value, child) => value ? child! : falseChild,
        child: trueChild,
      );
    } else {
      return ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, value, child) => value ? trueChild : child!,
        child: falseChild,
      );
    }
  }
}
