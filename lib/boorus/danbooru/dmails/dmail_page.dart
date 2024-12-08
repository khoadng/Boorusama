// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/level/colors.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../danbooru_provider.dart';
import '../users/creator/creators_notifier.dart';
import 'dmail_details_page.dart';
import 'providers.dart';

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
    final config = ref.watchConfigAuth;
    final dmailProvider = danbooruDmailsProvider((config, _selectedFolder));
    final dmailAsync = ref.watch(dmailProvider);
    final client = ref.watch(danbooruClientProvider(config));

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
                                          .toColor(context)
                                          .applyOpacity(0.7),
                                    )
                                  : TextStyle(
                                      color: fromUser?.level.toColor(context),
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
