// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../routers/common.dart';
import '../../../../routers/widgets/failsafe_page.dart';
import '../pages/details_layout_manager_page.dart';
import '../providers/details_layout_provider.dart';

final detailsManagerRoutes = GoRoute(
  path: 'details_manager',
  name: '/details_manager',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final params = castOrNull<DetailsLayoutManagerParams>(state.extra);

      if (params == null) {
        return InvalidPage(message: 'Invalid payload: $params');
      }

      return InheritedDetailsLayoutManagerParams(
        params: params,
        child: const DetailsLayoutManagerPage(),
      );
    },
  ),
);

class InheritedDetailsLayoutManagerParams extends InheritedWidget {
  const InheritedDetailsLayoutManagerParams({
    required this.params,
    required super.child,
    super.key,
  });

  final DetailsLayoutManagerParams params;

  static DetailsLayoutManagerParams of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<
        InheritedDetailsLayoutManagerParams>();
    if (widget == null) {
      throw Exception('InheritedDetailsLayoutManagerParams not found');
    }
    return widget.params;
  }

  @override
  bool updateShouldNotify(InheritedDetailsLayoutManagerParams oldWidget) {
    return oldWidget.params != params;
  }
}
