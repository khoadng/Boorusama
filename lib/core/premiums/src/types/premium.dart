// Package imports:
import 'package:equatable/equatable.dart';

const defaultBenefits = <Benefit>[
  Benefit(
    title: 'Customized layout',
    description:
        "Don't like the default layout? Want to see more or less information? Customize it!",
  ),
  Benefit(
    title: 'Customized theme',
    description:
        'More themes to choose from and customize. Each profile can have its own theme.',
  ),
  Benefit(
    title: 'Support indie developer',
    description:
        'Help me as a solo developer to keep the app updated and improving.',
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
