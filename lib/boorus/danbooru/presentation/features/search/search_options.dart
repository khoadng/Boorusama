// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/configs/config_provider.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/webview.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';
import 'search_history.dart';

final _config = Provider<IConfig>((ref) {
  return ref.watch(configProvider);
});

class SearchOptions extends HookWidget {
  const SearchOptions({
    Key key,
    this.onOptionTap,
    this.onHistoryTap,
  }) : super(key: key);

  final ValueChanged<String> onOptionTap;
  final ValueChanged<String> onHistoryTap;

  static const icons = {
    // "fav": Icons.favorite,
    "favcount": FontAwesomeIcons.sortAmountUp,
    // "id": FontAwesomeIcons.idCard,
    // "date": FontAwesomeIcons.calendar,
    "age": FontAwesomeIcons.clock,
    "rating": FontAwesomeIcons.exclamation,
    "score": FontAwesomeIcons.star,
  };

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: kThemeAnimationDuration);
    final config = useProvider(_config);

    useEffect(() {
      Future.delayed(
          Duration(milliseconds: 100), () => animationController.forward());
      return null;
    }, [animationController]);

    return FadeTransition(
      opacity: animationController,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Search Options".toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                .color,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        SlideInRoute(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  WebView(url: config.cheatSheetUrl),
                        ),
                      ),
                      icon: FaIcon(
                        FontAwesomeIcons.questionCircle,
                        size: 18,
                        color: Theme.of(context)
                            .appBarTheme
                            .actionsIconTheme
                            .color,
                      ),
                    )
                  ],
                ),
              ),
              ...config.searchOptions
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
                                  text: " ${config.searchOptionHitns[option]}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
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
