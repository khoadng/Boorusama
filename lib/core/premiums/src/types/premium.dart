// Package imports:
import 'package:equatable/equatable.dart';

const defaultBenefits = <Benefit>[
  Benefit(
    title: 'Exclusive Themes',
    description:
        'Pick from a variety of themes to personalize each profile’s look',
  ),
  Benefit(
    title: 'Layout & Home Screen',
    description:
        'Customize how much info you see, and set your preferred home screen (Bookmarks, Search, etc.)',
  ),
  Benefit(
    title: 'Enhanced Bulk Downloader',
    description:
        'Unlimited templates, multiple sessions and seamless resume after restart.',
  ),
  Benefit(
    title: 'Early Access',
    description:
        'Get a first look at experimental features before everyone else.',
  ),
  Benefit(
    title: 'Support Development',
    description:
        'Help a solo developer keep the project going with regular updates and improvements.',
  ),
];

class Benefit extends Equatable {
  const Benefit({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  List<Object?> get props => [title, description];
}

enum PremiumMode {
  hidden, // All premium features are hidden
  free, // All premium features are shown but user can't use them
  premium, // All premium features are shown and user can use them
}

PremiumMode parsePremiumMode(String? mode) => switch (mode) {
      'free' || 'disable' => PremiumMode.free,
      'premium' || 'enable' => PremiumMode.premium,
      _ => PremiumMode.hidden,
    };
