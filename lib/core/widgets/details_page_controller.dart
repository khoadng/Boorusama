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

mixin DetailsPageViewMixin on ChangeNotifier {
  Stream<PageDirection> get pageStream;
  StreamController<PageDirection> get pageStreamController;
  int get totalPages;
  ValueNotifier<int> get currentLocalPage;

  void Function(int page) get pageSyncronizer;

  void nextPage() {
    if (currentLocalPage.value < totalPages - 1) {
      pageStreamController.add(PageDirection.next);
    }
  }

  void previousPage() {
    if (currentLocalPage.value > 0) {
      pageStreamController.add(PageDirection.previous);
    }
  }
}

class DetailsPageMobileController extends ChangeNotifier
    with UIOverlayMixin, DetailsPageViewMixin {
  DetailsPageMobileController({
    bool hideOverlay = false,
    required this.initialPage,
    required this.totalPageFetcher,
    required this.pageSyncronizer,
  }) : _hideOverlay = ValueNotifier(hideOverlay);

  final _slideshow = ValueNotifier<bool>(false);
  final int Function() totalPageFetcher;
  late final ValueNotifier<bool> _hideOverlay;
  final int initialPage;

  @override
  final void Function(int page) pageSyncronizer;

  late final PostDetailsPageViewController _pageViewController =
      PostDetailsPageViewController(
    initialPage: initialPage,
  );

  @override
  int get totalPages => totalPageFetcher();

  @override
  final StreamController<PageDirection> pageStreamController =
      StreamController<PageDirection>.broadcast();

  @override
  Stream<PageDirection> get pageStream => pageStreamController.stream;

  @override
  ValueNotifier<bool> get hideOverlay => _hideOverlay;
  ValueNotifier<bool> get slideshow => _slideshow;

  @override
  ValueNotifier<int> get currentLocalPage =>
      _pageViewController.currentPageNotifier;
  ValueNotifier<bool> get expanded => _pageViewController.expandedNotifier;
  ValueNotifier<double> get topDisplacement =>
      _pageViewController.topDisplacement;

  void init() {
    currentLocalPage.addListener(_syncPage);
  }

  void _syncPage() {
    final page = currentLocalPage.value;
    pageSyncronizer(page);
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

  void resetSheet() {
    _pageViewController.resetSheet();
  }

  void setEnableSwiping(bool value) {
    if (value) {
      _pageViewController.enableAllSwiping();
    } else {
      _pageViewController.disableAllSwiping();
    }
  }

  @override
  void dispose() {
    currentLocalPage.removeListener(_syncPage);
    _pageViewController.dispose();
    pageStreamController.close();
    super.dispose();
  }
}

class DetailsPageDesktopController extends ChangeNotifier
    with UIOverlayMixin, DetailsPageViewMixin {
  DetailsPageDesktopController({
    required int initialPage,
    required this.totalPageFetcher,
    required this.pageSyncronizer,
    bool hideOverlay = false,
  })  : currentLocalPage = ValueNotifier(initialPage),
        currentRealtimePage = ValueNotifier(initialPage),
        _hideOverlay = ValueNotifier(hideOverlay);

  final ValueNotifier<bool> showInfo = ValueNotifier(false);
  final ValueNotifier<bool> pageSwipe = ValueNotifier(true);
  @override
  late final ValueNotifier<int> currentLocalPage;
  late final ValueNotifier<int> currentRealtimePage;
  final int Function() totalPageFetcher;
  @override
  int get totalPages => totalPageFetcher();

  @override
  final void Function(int page) pageSyncronizer;

  @override
  final StreamController<PageDirection> pageStreamController =
      StreamController<PageDirection>.broadcast();

  @override
  Stream<PageDirection> get pageStream => pageStreamController.stream;

  late final ValueNotifier<bool> _hideOverlay;

  @override
  ValueNotifier<bool> get hideOverlay => _hideOverlay;

  void toggleShowInfo() {
    showInfo.value = !showInfo.value;
    notifyListeners();
  }

  void setShowInfo(bool value) {
    showInfo.value = value;
    notifyListeners();
  }

  void changePage(int page) {
    currentLocalPage.value = page;
    pageSyncronizer(page);

    notifyListeners();
  }

  void changeRealtimePage(int page) {
    currentRealtimePage.value = page;
    notifyListeners();
  }

  void setEnablePageSwipe(bool value) {
    pageSwipe.value = value;
    notifyListeners();
  }
}
