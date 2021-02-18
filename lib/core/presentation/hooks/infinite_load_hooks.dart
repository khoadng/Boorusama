import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<bool> useRefreshingState(InfiniteLoadListController controller) {
  final isRefreshing = useState(false);
  final isMounted = useIsMounted();

  useEffect(() {
    controller.addListener(() {
      if (isMounted()) {
        isRefreshing.value = controller.isRefreshing;
      }
    });

    return null;
  }, [controller]);

  return isRefreshing;
}

typedef AutoRefreshConditionBuilder = bool Function();

void useAutoRefresh(InfiniteLoadListController controller, List<Object> keys,
    {AutoRefreshConditionBuilder refreshWhen}) {
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canRefresh = refreshWhen ?? () => true;
      if (canRefresh()) {
        controller.refresh();
      }
    });

    return null;
  }, keys);
}
