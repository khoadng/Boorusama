import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<bool> useRefreshingState(InfiniteLoadListController controller) {
  final isRefreshing = useState(false);

  useEffect(() {
    controller.addListener(() {
      isRefreshing.value = controller.isRefreshing;
    });

    return null;
  }, [controller]);

  return isRefreshing;
}

void useAutoRefresh(InfiniteLoadListController controller,
    [List<Object> keys]) {
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.refresh();
    });

    return null;
  }, keys);
}
