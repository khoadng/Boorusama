// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'search_history.dart';

class SearchOptions extends HookWidget {
  const SearchOptions({
    Key key,
    this.onOptionTap,
    this.onHistoryTap,
  }) : super(key: key);

  final ValueChanged<String> onOptionTap;
  final ValueChanged<String> onHistoryTap;

  static const options = [
    "fav",
    "favcount",
    "id",
    "date",
    "age",
    "rating",
    "score",
  ];

  static const hints = {
    "fav": "user",
    "favcount": ">10",
    "id": "1000, >=1000,",
    "date": "2007-01-01",
    "age": "2weeks..1year or age:2w..1y",
    "rating": "safe or s,...",
    "score": "100",
  };

  static const icons = {
    "fav": Icons.favorite,
    "favcount": FontAwesomeIcons.sortAmountUp,
    "id": FontAwesomeIcons.idCard,
    "date": FontAwesomeIcons.calendar,
    "age": FontAwesomeIcons.clock,
    "rating": FontAwesomeIcons.exclamation,
    "score": FontAwesomeIcons.star,
  };

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: kThemeAnimationDuration);

    useEffect(() {
      Future.delayed(
          Duration(milliseconds: 100), () => animationController.forward());
      return null;
    }, [animationController]);

    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Search Options".toUpperCase(),
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .appBarTheme
                            .actionsIconTheme
                            .color,
                      ),
                ),
              ),
              ...options
                  .map((option) => ListTile(
                        visualDensity: VisualDensity.compact,
                        onTap: () => onOptionTap(option),
                        title: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: "$option:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: " ${hints[option]}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        // leading: Icon(
                        //   icons[option],
                        //   color: Theme.of(context)
                        //       .appBarTheme
                        //       .actionsIconTheme
                        //       .color,
                        // ),
                      ))
                  .toList(),
              SearchHistorySection(
                onHistoryTap: (history) => onHistoryTap(history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
