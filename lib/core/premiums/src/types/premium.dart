// Package imports:
import 'package:equatable/equatable.dart';

const defaultBenefits = <Benefit>[
  Benefit(
    title: 'Exclusive themes',
    description:
        'Enjoy a variety of themes to choose from and customize. Give each profile its own unique look.',
  ),
  Benefit(
    title: 'Customize your layout',
    description:
        'Not a fan of the default layout? Want to see more or less info? Tweak it to your liking!',
  ),
  Benefit(
    title: 'Custom home screen',
    description:
        'Set your home screen to Bookmarks, Search, or any other page you prefer for quick access.',
  ),
  Benefit(
    title: 'Enhanced bulk downloader',
    description:
        'Unlimited templates, multiple sessions and seamless resume after restart.',
  ),
  Benefit(
    title: 'Early access',
    description:
        'Get exclusive early access to experimental features before they’re available to everyone else.',
  ),
  Benefit(
    title: 'Support development',
    description:
        'Run by one developer since 2020, this project relies on your support for ongoing updates and improvements.',
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
