// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/boot/providers.dart';
import '../../../foundation/display.dart';
import '../../router.dart';
import '../../widgets/booru_dialog.dart';
import 'donation_page.dart';

GoRoute donationRoutes(Ref ref) => GoRoute(
  path: 'donate',
  name: '/donate',
  redirect: (context, state) {
    // Redirect to premium page if not foss build
    if (!ref.read(isFossBuildProvider)) {
      return '/premium';
    }
    return null;
  },
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final landscape = context.orientation.isLandscape;

      const page = DonationPage();

      return landscape
          ? const BooruDialog(
              padding: EdgeInsets.all(8),
              child: page,
            )
          : page;
    },
  ),
);
