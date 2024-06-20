// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/feats/user_level_colors.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../danbooru_provider.dart';
import '../feats/dmails/dmails.dart';
import '../feats/users/users_provider.dart';
import 'danbooru_dmail_details_page.dart';

class DanbooruDmailPage extends ConsumerStatefulWidget {
  const DanbooruDmailPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruDmailPageState();
}

class _DanbooruDmailPageState extends ConsumerState<DanbooruDmailPage> {
  var _selectedFolder = DmailFolderType.received;

  @override
  Widget build(BuildContext context) {
    final dmailProvider =
        danbooruDmailsProvider((ref.watchConfig, _selectedFolder));
    final dmailAsync = ref.watch(dmailProvider);
    final client = ref.watch(danbooruClientProvider(ref.watchConfig));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
              icon: const Icon(Symbols.refresh),
              onPressed: () => ref.invalidate(dmailProvider)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: _selectedFolder,
                onChanged: (value) => setState(
                    () => _selectedFolder = value ?? DmailFolderType.all),
                items: DmailFolderType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.sentenceCase),
                        ))
                    .toList()),
          ),
          dmailAsync.when(
            data: (dmails) => dmails.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: dmails.length,
                      itemBuilder: (context, index) {
                        final dmail = dmails[index];
                        final fromUser =
                            ref.watch(danbooruCreatorProvider(dmail.fromId));

                        return ListTile(
                            minVerticalPadding: 0,
                            visualDensity: VisualDensity.compact,
                            trailing: DateTooltip(
                              date: dmail.createdAt,
                              child: Text(
                                dmail.createdAt.fuzzify(
                                    locale: Localizations.localeOf(context)),
                              ),
                            ),
                            title: Text(
                              fromUser?.name ?? '...',
                              style: dmail.isRead
                                  ? TextStyle(
                                      color: fromUser?.level
                                          .toOnDarkColor()
                                          .withOpacity(0.7),
                                    )
                                  : TextStyle(
                                      color: fromUser?.level.toOnDarkColor(),
                                      fontWeight: FontWeight.w900,
                                    ),
                            ),
                            subtitle: Text(
                              dmail.title,
                              overflow: TextOverflow.ellipsis,
                              style: dmail.isRead
                                  ? null
                                  : const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                            ),
                            onTap: () {
                              if (!dmail.isRead) {
                                client.markDmailAsRead(id: dmail.id).then(
                                    (value) => ref.invalidate(dmailProvider));
                              }
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      DanbooruDmailDetailsPage(
                                    dmail: dmail,
                                    onDmailUnread: (context, dmail) {
                                      client
                                          .markDmailAsUnread(id: dmail.id)
                                          .then((value) =>
                                              ref.invalidate(dmailProvider));
                                    },
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  )
                : const GenericNoDataBox(text: 'No messages found'),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
