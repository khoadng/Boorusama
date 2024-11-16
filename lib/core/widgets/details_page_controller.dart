part of 'details_page.dart';

enum PageDirection {
  next,
  previous,
}

mixin UIOverlayMixin on ChangeNotifier {
  ValueNotifier<bool> get hideOverlay;

  void toggleOverlay() {
    hideOverlay.value = !hideOverlay.value;
    if (hideOverlay.value) {
      hideSystemStatus();
    } else {
      showSystemStatus();
    }
    notifyListeners();
  }

  // set overlay value
  void setHideOverlay(bool value) {
    hideOverlay.value = value;
    notifyListeners();
  }

  void restoreSystemStatus() {
    showSystemStatus();
  }
}

class DetailsPageController extends ChangeNotifier with UIOverlayMixin {
  DetailsPageController({
    bool hideOverlay = false,
    int initialPage = 0,
  })  : currentPage = ValueNotifier(initialPage),
        _hideOverlay = ValueNotifier(hideOverlay);

  final _slideshow = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _hideOverlay;

  late final PostDetailsPageViewController pageViewController =
      PostDetailsPageViewController(
    initialPage: currentPage.value,
  );

  @override
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<bool> get slideshow => _slideshow;

  // use stream event to change to next page or previous page
  final StreamController<PageDirection> _pageController =
      StreamController<PageDirection>.broadcast();

  Stream<PageDirection> get pageStream => _pageController.stream;

  late final ValueNotifier<int> currentPage;

  void nextPage() {
    _pageController.add(PageDirection.next);
  }

  void previousPage() {
    _pageController.add(PageDirection.previous);
  }

  void startSlideshow() {
    _slideshow.value = true;
    if (!_hideOverlay.value) setHideOverlay(true);
    hideSystemStatus();
    notifyListeners();
  }

  void stopSlideshow() {
    _slideshow.value = false;
    setHideOverlay(false);
    showSystemStatus();
    notifyListeners();
  }

  void setEnableSwiping(bool value) {
    if (value) {
      pageViewController.enableAllSwiping();
    } else {
      pageViewController.disableAllSwiping();
    }
  }

  @override
  void dispose() {
    _pageController.close();
    pageViewController.dispose();
    super.dispose();
  }
}
