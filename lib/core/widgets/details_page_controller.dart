part of 'details_page.dart';

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
}
