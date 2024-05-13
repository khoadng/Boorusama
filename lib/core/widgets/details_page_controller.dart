part of 'details_page.dart';

class DetailsPageController extends ChangeNotifier {
  DetailsPageController({
    bool swipeDownToDismiss = true,
    bool hideOverlay = false,
  })  : _enableSwipeDownToDismiss = swipeDownToDismiss,
        _hideOverlay = ValueNotifier(hideOverlay);

  var _enableSwipeDownToDismiss = false;

  var _enablePageSwipe = true;
  final _slideShow = ValueNotifier((false, <int>[]));
  late final ValueNotifier<bool> _hideOverlay;

  bool get swipeDownToDismiss => _enableSwipeDownToDismiss;
  bool get pageSwipe => _enablePageSwipe;
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<(bool, List<int>)> get slideShow => _slideShow;

  void toggleSlideShow() {
    if (_slideShow.value.$1) {
      stopSlideShow();
    } else {
      startSlideShow();
    }
  }

  void startSlideShow({
    List<int>? skipIndexes,
  }) {
    _slideShow.value = (true, skipIndexes ?? <int>[]);
    disablePageSwipe();
    disableSwipeDownToDismiss();
    if (!_hideOverlay.value) setHideOverlay(true);
    notifyListeners();
  }

  void stopSlideShow() {
    _slideShow.value = (false, <int>[]);
    enablePageSwipe();
    enableSwipeDownToDismiss();
    // already changed by image tap
    // setHideOverlay(false);

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
