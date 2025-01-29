// Package imports:
import 'package:equatable/equatable.dart';

const defaultBenefits = <Benefit>[
  Benefit(
    title: 'Themes',
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
        'Set your home screen to Bookmarks, Search, or any other page you prefer.',
  ),
  Benefit(
    title: 'Support indie developer',
    description:
        'Support my solo development efforts so I can keep rolling out updates and improvements.',
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
