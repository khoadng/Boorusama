final defaultBenefits = <Benefit>[
  (
    title: 'Customized layout for each profile',
    description:
        "Don't like the default layout? Want to see more or less information? Customize it!",
  ),
  (
    title: 'Customized theme',
    description:
        'Do you want each profile to have a different theme? You can do it!',
  ),
  (
    title: 'Support indie developer',
    description: 'Help me as a solo developer to keep the app improving!',
  ),
];

typedef Benefit = ({
  String title,
  String description,
});

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
