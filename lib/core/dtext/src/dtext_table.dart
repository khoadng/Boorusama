// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dtext/dtext.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import '../../configs/config/types.dart';
import '../../text_markup/types.dart';
import '../../../foundation/html.dart';
import 'dtext_emoji_renderer.dart';
import 'dtext_html.dart';

class DTextTable extends StatelessWidget {
  const DTextTable({
    required this.node,
    required this.emojiMap,
    required this.emojiSize,
    required this.emojiImageConfig,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
    super.key,
  });

  final DTextElementNode node;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final BooruConfigAuth? emojiImageConfig;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final rows = _tableRows(node);
    if (rows.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outlineVariant;
    final stripeColor = colorScheme.surfaceContainerHighest;
    final columnCount = rows
        .map((row) => row.cells.length)
        .fold<int>(0, (max, count) => count > max ? count : max);
    if (columnCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder(
            top: BorderSide(color: borderColor),
            horizontalInside: BorderSide(color: borderColor),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            for (final (index, row) in rows.indexed)
              TableRow(
                decoration: BoxDecoration(
                  color: index.isOdd ? stripeColor : null,
                ),
                children: [
                  for (final cell in _normalizedCells(row, columnCount))
                    _DTextTableCell(
                      cell: cell,
                      emojiMap: emojiMap,
                      emojiSize: emojiSize,
                      emojiImageConfig: emojiImageConfig,
                      style: style,
                      onLinkTap: onLinkTap,
                      selectable: selectable,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DTextTableCell extends StatelessWidget {
  const _DTextTableCell({
    required this.cell,
    required this.emojiMap,
    required this.emojiSize,
    required this.emojiImageConfig,
    required this.style,
    required this.onLinkTap,
    required this.selectable,
  });

  final _DTextTableCellData cell;
  final Map<String, TextEmoji> emojiMap;
  final double emojiSize;
  final BooruConfigAuth? emojiImageConfig;
  final Map<String, Style>? style;
  final OnTap? onLinkTap;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final htmlStyle = dTextHtmlStyle(style);
    if (cell.isHeader) {
      htmlStyle['body'] = htmlStyle['body']!.merge(
        Style(fontWeight: FontWeight.bold),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AppHtml(
          data: renderDTextNodesHtml(
            cell.children,
            emojiMap: emojiMap,
            emojiSize: emojiSize,
            emojiImageConfig: emojiImageConfig,
          ),
          style: htmlStyle,
          onLinkTap: onLinkTap,
          extensions: [
            if (emojiImageConfig case final config?)
              ...dTextEmojiHtmlExtensions(config),
          ],
          selectable: selectable,
        ),
      ),
    );
  }
}

class _DTextTableRowData {
  const _DTextTableRowData(this.cells);

  final List<_DTextTableCellData> cells;
}

class _DTextTableCellData {
  const _DTextTableCellData({
    required this.children,
    required this.isHeader,
  });

  final List<DTextNode> children;
  final bool isHeader;
}

List<_DTextTableRowData> _tableRows(DTextElementNode table) {
  final rows = <_DTextTableRowData>[];

  void visit(List<DTextNode> nodes) {
    final directCells = <_DTextTableCellData>[];

    for (final node in nodes) {
      switch (node) {
        case DTextElementNode(
          element: DTextElement.tableHead || DTextElement.tableBody,
          :final children,
        ):
          if (directCells.isNotEmpty) {
            rows.add(_DTextTableRowData(List.unmodifiable(directCells)));
            directCells.clear();
          }
          visit(children);
        case DTextElementNode(element: DTextElement.tableRow):
          if (directCells.isNotEmpty) {
            rows.add(_DTextTableRowData(List.unmodifiable(directCells)));
            directCells.clear();
          }
          rows.add(_DTextTableRowData(_tableCells(node)));
        case DTextElementNode(
          element: DTextElement.tableHeader || DTextElement.tableCell,
        ):
          directCells.add(_tableCell(node));
        default:
          break;
      }
    }

    if (directCells.isNotEmpty) {
      rows.add(_DTextTableRowData(List.unmodifiable(directCells)));
    }
  }

  visit(table.children);

  return List.unmodifiable(rows);
}

List<_DTextTableCellData> _tableCells(DTextElementNode row) =>
    List.unmodifiable([
      for (final node in row.children)
        if (node case DTextElementNode(
          element: DTextElement.tableHeader || DTextElement.tableCell,
        ))
          _tableCell(node),
    ]);

_DTextTableCellData _tableCell(DTextElementNode cell) {
  return _DTextTableCellData(
    children: cell.children,
    isHeader: cell.element == DTextElement.tableHeader,
  );
}

List<_DTextTableCellData> _normalizedCells(
  _DTextTableRowData row,
  int columnCount,
) {
  if (row.cells.length >= columnCount) return row.cells;

  return [
    ...row.cells,
    for (var i = row.cells.length; i < columnCount; i++)
      const _DTextTableCellData(
        children: [],
        isHeader: false,
      ),
  ];
}
