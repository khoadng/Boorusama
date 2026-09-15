// Package imports:
import 'package:kurumi/cupertino.dart';

const _kSettingsTransitionDuration = Duration(milliseconds: 300);

class SettingsAdaptivePage<T> extends Page<T> {
  const SettingsAdaptivePage({
    required this.child,
    required this.animate,
    this.title,
    this.maintainState = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool animate;
  final String? title;
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) =>
      SettingsAdaptivePageRoute<T>(this);
}

class SettingsAdaptivePageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  SettingsAdaptivePageRoute(SettingsAdaptivePage<T> page)
    : super(settings: page);

  SettingsAdaptivePage<T> get _page => settings as SettingsAdaptivePage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  String? get title => _page.title;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => false;

  @override
  Duration get transitionDuration =>
      _page.animate ? _kSettingsTransitionDuration : Duration.zero;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _page.animate ? CupertinoPageTransition.delegatedTransition : null;

  @override
  bool get popGestureEnabled => _page.animate && super.popGestureEnabled;

  @override
  void changedInternalState() {
    super.changedInternalState();

    final animationController = controller;
    if (animationController == null) return;
    animationController
      ..duration = transitionDuration
      ..reverseDuration = reverseTransitionDuration;
  }
}
