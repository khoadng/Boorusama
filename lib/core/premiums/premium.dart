final defaultBenefits = <Benefit>[
  (
    title: 'Customized layout for each profile',
    description:
        'Don\'t like the default layout? Want to see more or less information? Customize it!',
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
