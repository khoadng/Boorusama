// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../router.dart';
import 'donation_page.dart';

Future<void> goToDonationPage(BuildContext context) {
  return context.pushNamed(
    '/donate',
    extra: const DonationPage(),
  );
}
