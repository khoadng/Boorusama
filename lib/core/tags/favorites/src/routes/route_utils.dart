// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

void goToFavoriteTagsPage(BuildContext context) {
  context.push(
    Uri(
      path: '/favorite_tags',
    ).toString(),
  );
}
