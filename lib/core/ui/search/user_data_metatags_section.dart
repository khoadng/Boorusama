// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/ui/search/metatags_section.dart';

class UserDataMetatagsSection extends StatelessWidget {
  const UserDataMetatagsSection({
    super.key,
    this.onOptionTap,
    required this.metatags,
    required this.onHelpRequest,
    required this.userMetatagRepository,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;
  final void Function() onHelpRequest;
  final UserMetatagRepository userMetatagRepository;

  @override
  Widget build(BuildContext context) {
    return MetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      userMetatags: () => userMetatagRepository.getAll(),
      onHelpRequest: onHelpRequest,
      onUserMetatagDeleted: (tag) => userMetatagRepository.delete(tag),
      onUserMetatagAdded: (tag) => userMetatagRepository.put(tag.name),
    );
  }
}
