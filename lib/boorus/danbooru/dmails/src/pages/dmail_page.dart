// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../users/creator/providers.dart';
import '../../../users/user/providers.dart';
import '../providers/dmail_provider.dart';
import '../providers/folder_provider.dart';
import '../routes/route_utils.dart';
import '../types/dmail.dart';

class DanbooruDmailPage extends ConsumerStatefulWidget {
  const DanbooruDmailPage({
    super.key,
    this.initialFolder,
  });

  final String? initialFolder;

  @override
  ConsumerState<DanbooruDmailPage> createState() => _DanbooruDmailPageState();
}

class _DanbooruDmailPageState extends ConsumerState<DanbooruDmailPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dmailFolderProvider(ref.readConfigAuth).notifier)
          .changeFolderFromString(widget.initialFolder);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final selectedFolder = ref.watch(dmailFolderProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.profile.messages.title),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () =>
                ref.read(danbooruDmailsProvider(config).notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: selectedFolder,
              onChanged: (value) => ref
                  .read(dmailFolderProvider(config).notifier)
                  .changeFolder(value ?? DmailFolderType.all),
              items: DmailFolderType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(switch (e) {
                        DmailFolderType.all =>
                          context.t.profile.messages.categories.all,
                        DmailFolderType.received =>
                          context.t.profile.messages.categories.received,
                        DmailFolderType.unread =>
                          context.t.profile.messages.categories.unread,
                        DmailFolderType.sent =>
                          context.t.profile.messages.categories.sent,
                        DmailFolderType.deleted =>
                          context.t.profile.messages.categories.deleted,
                      }),
                    ),
                  )
                  .toList(),
            ),
          ),
          ref
              .watch(danbooruDmailsProvider(config))
              .when(
                data: (dmails) => dmails.isNotEmpty
                    ? Expanded(
                        child: _buildList(dmails, ref, config),
                      )
                    : GenericNoDataBox(text: context.t.profile.messages.empty),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Dmail> dmails,
    WidgetRef ref,
    BooruConfigAuth config,
  ) {
    final userColor = DanbooruUserColor.of(ref.context);

    return ListView.builder(
      itemCount: dmails.length,
      itemBuilder: (context, index) {
        final dmail = dmails[index];

        return ListTile(
          minVerticalPadding: 0,
          visualDensity: VisualDensity.compact,
          trailing: DateTooltip(
            date: dmail.createdAt,
            child: Text(
              dmail.createdAt.fuzzify(
                locale: Localizations.localeOf(context),
              ),
            ),
          ),
          title: Builder(
            builder: (context) {
              final fromUser = ref.watch(
                danbooruCreatorProvider(dmail.fromId),
              );

              final color = userColor.fromLevel(
                fromUser?.level,
              );

              return Text(
                fromUser?.name ?? '...',
                style: dmail.isRead
                    ? TextStyle(
                        color: color.withValues(alpha: 0.7),
                      )
                    : TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
              );
            },
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
              ref
                  .read(danbooruDmailsProvider(config).notifier)
                  .markAsRead(dmail.id);
            }

            goToDmailDetailsPage(ref, dmailId: dmail.id);
          },
        );
      },
    );
  }
}
