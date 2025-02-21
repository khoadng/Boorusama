// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiValueListenableBuilder2<A, B> extends StatelessWidget {
  const MultiValueListenableBuilder2({
    required this.first,
    required this.second,
    required this.builder,
    super.key,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext context, A a, B b) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, aValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, bValue, _) {
            return builder(context, aValue, bValue);
          },
        );
      },
    );
  }
}

class MultiValueListenableBuilder3<A, B, C> extends StatelessWidget {
  const MultiValueListenableBuilder3({
    required this.first,
    required this.second,
    required this.third,
    required this.builder,
    super.key,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget Function(BuildContext context, A a, B b, C c) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, aValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, bValue, _) {
            return ValueListenableBuilder<C>(
              valueListenable: third,
              builder: (context, cValue, _) {
                return builder(context, aValue, bValue, cValue);
              },
            );
          },
        );
      },
    );
  }
}

class MultiValueListenableBuilder4<A, B, C, D> extends StatelessWidget {
  const MultiValueListenableBuilder4({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.builder,
    super.key,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final ValueListenable<D> fourth;
  final Widget Function(BuildContext context, A a, B b, C c, D d) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, aValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, bValue, _) {
            return ValueListenableBuilder<C>(
              valueListenable: third,
              builder: (context, cValue, _) {
                return ValueListenableBuilder<D>(
                  valueListenable: fourth,
                  builder: (context, dValue, _) {
                    return builder(context, aValue, bValue, cValue, dValue);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
