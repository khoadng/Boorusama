// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/core/utils.dart';
import 'search_history.dart';

class SearchOptions extends HookWidget {
  const SearchOptions({
    Key? key,
    required this.config,
    this.onOptionTap,
    this.onHistoryTap,
  }) : super(key: key);

  final ValueChanged<String>? onOptionTap;
  final ValueChanged<String>? onHistoryTap;

  static const icons = {
    // "fav": Icons.favorite,
    'favcount': FontAwesomeIcons.arrowUpWideShort,
    // "id": FontAwesomeIcons.idCard,
    // "date": FontAwesomeIcons.calendar,
    'age': FontAwesomeIcons.clock,
    'rating': FontAwesomeIcons.exclamation,
    'score': FontAwesomeIcons.star,
  };

  final IConfig config;

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: kThemeAnimationDuration);

    useEffect(() {
      Future.delayed(
        const Duration(milliseconds: 100),
        animationController.forward,
      );
      return null;
    }, [animationController]);

    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Options'.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    IconButton(
                      onPressed: () {
                        launchExternalUrl(
                          Uri.parse(config.cheatSheetUrl),
                          mode: LaunchMode.platformDefault,
                        );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.circleQuestion,
                        size: 18,
                      ),
                    )
                  ],
                ),
              ),
              ...config.searchOptions
                  .map((option) => ListTile(
                        visualDensity: VisualDensity.compact,
                        onTap: () => onOptionTap?.call(option),
                        title: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: '$option:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: ' ${config.searchOptionHitns[option]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
              SearchHistorySection(
                onHistoryTap: (history) => onHistoryTap?.call(history),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
