part of 'details_page.dart';

enum PageDirection {
  next,
  previous,
}

class DetailsPageController extends ChangeNotifier {
  DetailsPageController({
    bool swipeDownToDismiss = true,
    bool hideOverlay = false,
  })  : _enableSwipeDownToDismiss = swipeDownToDismiss,
        _hideOverlay = ValueNotifier(hideOverlay);

  var _enableSwipeDownToDismiss = false;

  var _enablePageSwipe = true;
  final _slideshow = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _hideOverlay;

  bool get swipeDownToDismiss => _enableSwipeDownToDismiss;
  bool get pageSwipe => _enablePageSwipe;
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<bool> get slideshow => _slideshow;

  // use stream event to change to next page or previous page
  final StreamController<PageDirection> _pageController =
      StreamController<PageDirection>.broadcast();

  Stream<PageDirection> get pageStream => _pageController.stream;

  void nextPage() {
    _pageController.add(PageDirection.next);
  }

  void previousPage() {
    _pageController.add(PageDirection.previous);
  }

  void startSlideshow() {
    _slideshow.value = true;
    disablePageSwipe();
    disableSwipeDownToDismiss();
    if (!_hideOverlay.value) setHideOverlay(true);
    notifyListeners();
  }

  void stopSlideshow() {
    _slideshow.value = false;
    enablePageSwipe();
    enableSwipeDownToDismiss();
    setHideOverlay(false);

    notifyListeners();
  }

  void enableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = true;
    notifyListeners();
  }

  void disableSwipeDownToDismiss() {
    _enableSwipeDownToDismiss = false;
    notifyListeners();
  }

  void enablePageSwipe() {
    _enablePageSwipe = true;
    notifyListeners();
  }

  void disablePageSwipe() {
    _enablePageSwipe = false;
    notifyListeners();
  }

  // set overlay value
  void setHideOverlay(bool value) {
    _hideOverlay.value = value;
    notifyListeners();
  }

  // set enable swipe page
  void setEnablePageSwipe(bool value) {
    _enablePageSwipe = value;
    notifyListeners();
  }

  void toggleOverlay() {
    _hideOverlay.value = !_hideOverlay.value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.close();
    super.dispose();
  }
}
