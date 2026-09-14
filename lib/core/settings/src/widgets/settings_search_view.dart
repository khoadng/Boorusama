// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../types/settings_search_entry.dart';
import '../types/settings_search_matcher.dart';
import 'settings_search_result_tile.dart';

class SettingsSearchView extends StatefulWidget {
  const SettingsSearchView({
    required this.entries,
    required this.onOpen,
    required this.onClose,
    this.detail,
    this.navigation,
    this.autofocus = true,
    this.activeEntryId,
    this.onSearchChanged,
    super.key,
  });

  final List<SettingsSearchEntry> entries;
  final Future<void> Function(SettingsSearchEntry) onOpen;
  final VoidCallback onClose;
  final Widget? detail;
  final Widget? navigation;
  final bool autofocus;
  final String? activeEntryId;
  final VoidCallback? onSearchChanged;

  @override
  State<SettingsSearchView> createState() => _SettingsSearchViewState();
}

class _SettingsSearchViewState extends State<SettingsSearchView> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  var _keyboardSelection = false;
  final _keys = <String, GlobalKey>{};
  var _selected = 0;
  var _opening = false;

  List<SettingsSearchEntry> get _results => searchSettings(
    widget.entries,
    _query.text,
  );

  Future<void> _open(SettingsSearchEntry entry) async {
    if (_opening) return;
    setState(() => _opening = true);
    final inline = widget.detail != null;
    if (!inline) _focus.unfocus();
    try {
      await widget.onOpen(entry);
    } finally {
      if (mounted) {
        setState(() => _opening = false);
        if (inline) _focus.requestFocus();
      }
    }
  }

  void _openSelected() {
    final results = _results;
    if (results.isNotEmpty) {
      _open(results[_selected.clamp(0, results.length - 1)]);
    }
  }

  void _move(int delta) {
    final results = _results;
    if (results.isEmpty) return;
    setState(() {
      _keyboardSelection = true;
      _selected = (_selected + delta).clamp(0, results.length - 1);
    });
    final target = _keys[results[_selected].id]?.currentContext;
    if (target != null) Scrollable.ensureVisible(target, alignment: 0.5);
  }

  void _searchChanged() {
    setState(() {
      _selected = 0;
      _keyboardSelection = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    widget.onSearchChanged?.call();
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final selected = results.isEmpty
        ? 0
        : _selected.clamp(0, results.length - 1);
    final theme = Kurumi.themeOf(context);
    final dialog = context.findAncestorWidgetOfExactType<KurumiDialog>();
    final backgroundColor = dialog == null
        ? theme.scaffoldBackgroundColor
        : dialog.color ?? theme.colorScheme.surface;
    final strings = context.t.settings_search;
    final emptyQuery = normalizeSettingsQuery(_query.text).isEmpty;
    final resultsView = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: emptyQuery && widget.navigation != null
              ? widget.navigation!
              : emptyQuery || results.isEmpty
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      for (var i = 0; i < results.length; i++)
                        SettingsSearchResultTile(
                          key: _keys.putIfAbsent(results[i].id, GlobalKey.new),
                          entry: results[i],
                          compact: widget.detail != null,
                          selected: widget.activeEntryId == results[i].id,
                          keyboardFocused: _keyboardSelection && i == selected,
                          onTap: _opening
                              ? null
                              : () {
                                  setState(() {
                                    _selected = i;
                                    _keyboardSelection = false;
                                  });
                                  _open(results[i]);
                                },
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );

    final searchField = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
      },
      child: KurumiSearchBar(
        controller: _query,
        focus: _focus,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        hintText: strings.title,
        leading: widget.detail == null
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Symbols.arrow_back),
                onPressed: widget.onClose,
              )
            : const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Symbols.search, size: 20),
              ),
        trailing: _query.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.t.generic.action.clear,
                icon: const Icon(Symbols.close, size: 18),
                onPressed: () {
                  _query.clear();
                  _searchChanged();
                  _focus.requestFocus();
                },
              ),
        onChanged: (_) => _searchChanged(),
        onSubmitted: (_) => _openSelected(),
      ),
    );
    return Focus(
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (widget.detail != null) {
            if (_query.text.isNotEmpty) {
              _query.clear();
              _searchChanged();
            } else {
              _focus.unfocus();
            }
          } else {
            widget.onClose();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: widget.detail == null
          ? Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: backgroundColor,
                automaticallyImplyLeading: false,
                title: searchField,
              ),
              body: SafeArea(child: resultsView),
            )
          : InlineSettingsSearch(
              focusSearch: _focus.requestFocus,
              child: Material(
                color: backgroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      key: const ValueKey('settings-search-sidebar'),
                      width: 300,
                      child: Material(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: SafeArea(
                          right: false,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: searchField,
                              ),
                              Expanded(child: resultsView),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: SafeArea(
                        left: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            key: const ValueKey('settings-search-detail'),
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: widget.detail,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Descendant controls focus the existing sidebar instead of opening a route.
class InlineSettingsSearch extends InheritedWidget {
  const InlineSettingsSearch({
    required this.focusSearch,
    required super.child,
    super.key,
  });
  final VoidCallback focusSearch;
  static InlineSettingsSearch? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InlineSettingsSearch>();
  @override
  bool updateShouldNotify(InlineSettingsSearch oldWidget) =>
      focusSearch != oldWidget.focusSearch;
}
