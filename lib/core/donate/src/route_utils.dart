// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../router.dart';
import 'donation_page.dart';

Future<void> goToDonationPage(WidgetRef ref) {
  return ref.router.pushNamed(
    '/donate',
    extra: const DonationPage(),
  );
}
