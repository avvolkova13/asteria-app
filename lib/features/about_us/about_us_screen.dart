import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_inline_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key, this.initialDocument});

  final LegalDocumentType? initialDocument;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: ProfileFlowBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AsteriaEntrance.sections([
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ProfileFlowHeader(
                    title: context.l10n.aboutTitle,
                    canPop: true,
                  ),
                ),
                const SizedBox(height: 18),
                _AboutUsContentItemWithAsset(
                  title: context.l10n.agreementText,
                  shortDescription: context.l10n.agreementSummary,
                  initiallyExpanded:
                      initialDocument == LegalDocumentType.agreement,
                  assetPath: LegalAssetResolver.resolve(
                    document: LegalDocumentType.agreement,
                    languageCode: languageCode,
                    platform: defaultTargetPlatform,
                  ),
                ),
                const SizedBox(height: 16),
                _AboutUsContentItemWithAsset(
                  title: context.l10n.policyText,
                  shortDescription: context.l10n.privacySummary,
                  initiallyExpanded:
                      initialDocument == LegalDocumentType.privacy,
                  assetPath: LegalAssetResolver.resolve(
                    document: LegalDocumentType.privacy,
                    languageCode: languageCode,
                    platform: defaultTargetPlatform,
                  ),
                ),
                const SizedBox(height: 16),
                _AboutUsContentItem(
                  title: context.l10n.subscriptionInfoTitle,
                  shortDescription: context.l10n.subscriptionInfoDescription,
                ),
                const SizedBox(height: 16),
                _AboutUsContentItem(
                  title: context.l10n.licensesTitle,
                  shortDescription: context.l10n.licensesDescription,
                  links: const [
                    (
                      text: 'HadiSharifani',
                      url: 'https://www.figma.com/@hicon',
                    ),
                    (
                      text: 'CC BY 4.0',
                      url: 'https://creativecommons.org/licenses/by/4.0/',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AboutUsContentItem(
                  title: context.l10n.contactsTitle,
                  shortDescription: context.l10n.contactsDescription,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutUsContentItem extends StatelessWidget {
  const _AboutUsContentItem({
    required this.title,
    required this.shortDescription,
    this.links = const [],
  });

  final String title;
  final String shortDescription;
  final List<({String text, String url})> links;

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.inversePlayfairSemiBold20.copyWith(
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          _LinkedText(text: shortDescription, links: links),
        ],
      ),
    );
  }
}

class _AboutUsContentItemWithAsset extends StatefulWidget {
  const _AboutUsContentItemWithAsset({
    required this.title,
    required this.shortDescription,
    required this.assetPath,
    this.initiallyExpanded = false,
  });

  final String title;
  final String shortDescription;
  final String assetPath;
  final bool initiallyExpanded;

  @override
  State<_AboutUsContentItemWithAsset> createState() =>
      _AboutUsContentItemWithAssetState();
}

class _AboutUsContentItemWithAssetState
    extends State<_AboutUsContentItemWithAsset> {
  List<_LegalDocumentBlock>? _fullDocument;
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.initiallyExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssetText());
    }
  }

  Future<void> _loadAssetText() async {
    if (_fullDocument != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final text = await rootBundle.loadString(widget.assetPath);
      final document = _LegalDocumentParser.parse(text);
      if (!mounted) return;
      setState(() {
        _fullDocument = document;
        _isExpanded = true;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  void _toggleExpansion() {
    if (_fullDocument == null && !_isLoading) {
      _loadAssetText();
      return;
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isShowingFullDocument = _isExpanded && _fullDocument != null;

    return ProfileGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      onTap: _toggleExpansion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: context.textTheme.inversePlayfairSemiBold20.copyWith(
                    height: 1,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadFailed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                context.l10n.legalDocumentUnavailable,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: ProfileFlowColors.textMuted,
                ),
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isShowingFullDocument
                ? _LegalDocumentView(
                    key: const ValueKey('full-legal-document'),
                    blocks: _fullDocument!,
                  )
                : _LinkedText(
                    key: const ValueKey('legal-document-description'),
                    text: widget.shortDescription,
                    links: const [],
                  ),
          ),
        ],
      ),
    );
  }
}

sealed class _LegalDocumentBlock {
  const _LegalDocumentBlock();
}

class _LegalTextBlock extends _LegalDocumentBlock {
  const _LegalTextBlock(this.text);

  final String text;
}

class _LegalTableBlock extends _LegalDocumentBlock {
  const _LegalTableBlock(this.rows);

  final List<List<String>> rows;
}

class _LegalDocumentParser {
  static const _tableStart = '[[table]]';
  static const _tableEnd = '[[/table]]';
  static const _rowStart = '[[row]]';
  static const _cellStart = '[[cell]]';

  static List<_LegalDocumentBlock> parse(String source) {
    final blocks = <_LegalDocumentBlock>[];
    final textLines = <String>[];
    List<List<String>>? tableRows;
    List<String>? currentRow;
    List<String>? currentCellLines;

    void flushText() {
      final text = textLines.join('\n').trim();
      if (text.isNotEmpty) blocks.add(_LegalTextBlock(text));
      textLines.clear();
    }

    void flushCell() {
      final cellLines = currentCellLines;
      if (cellLines == null) return;
      final row = currentRow;
      if (row == null) {
        throw const FormatException('A legal document cell must be in a row.');
      }
      row.add(cellLines.join('\n').trim());
      currentCellLines = null;
    }

    void flushRow() {
      flushCell();
      final row = currentRow;
      if (row == null) return;
      if (row.isEmpty) {
        throw const FormatException('A legal document row cannot be empty.');
      }
      tableRows!.add(List.unmodifiable(row));
      currentRow = null;
    }

    final lines = source.replaceAll('\r\n', '\n').split('\n');
    for (final line in lines) {
      switch (line) {
        case _tableStart:
          if (tableRows != null) {
            throw const FormatException('Legal document tables cannot nest.');
          }
          flushText();
          tableRows = [];
        case _rowStart:
          if (tableRows == null) {
            throw const FormatException('A legal document row needs a table.');
          }
          flushRow();
          currentRow = [];
        case _cellStart:
          if (currentRow == null) {
            throw const FormatException('A legal document cell needs a row.');
          }
          flushCell();
          currentCellLines = [];
        case _tableEnd:
          if (tableRows == null) {
            throw const FormatException('Unexpected legal document table end.');
          }
          flushRow();
          if (tableRows.isEmpty) {
            throw const FormatException(
              'A legal document table cannot be empty.',
            );
          }
          final columnCount = tableRows.first.length;
          if (columnCount == 0 ||
              tableRows.any((row) => row.length != columnCount)) {
            throw const FormatException(
              'All legal document table rows must have the same cell count.',
            );
          }
          blocks.add(_LegalTableBlock(List.unmodifiable(tableRows)));
          tableRows = null;
        default:
          if (tableRows == null) {
            textLines.add(line);
          } else if (currentCellLines case final cellLines?) {
            cellLines.add(line);
          } else if (line.isNotEmpty) {
            throw const FormatException(
              'Table content must be placed inside a legal document cell.',
            );
          }
      }
    }

    if (tableRows != null) {
      throw const FormatException('Unclosed legal document table.');
    }
    flushText();
    return List.unmodifiable(blocks);
  }
}

class _LegalDocumentView extends StatelessWidget {
  const _LegalDocumentView({super.key, required this.blocks});

  final List<_LegalDocumentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var tableIndex = 0;

    for (final block in blocks) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));

      switch (block) {
        case _LegalTextBlock(:final text):
          children.add(_LinkedText(text: text, links: const []));
        case _LegalTableBlock(:final rows):
          children.add(_LegalDocumentTable(rows: rows, index: tableIndex));
          tableIndex++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _LegalDocumentTable extends StatelessWidget {
  const _LegalDocumentTable({required this.rows, required this.index});

  final List<List<String>> rows;
  final int index;

  @override
  Widget build(BuildContext context) {
    final columnCount = rows.first.length;
    final minimumWidth = columnCount == 3 ? 720.0 : 600.0;
    final regularStyle = context.textTheme.inverseUrbanistRegular14.copyWith(
      fontSize: 13,
      height: 1.18,
    );
    final headerStyle = regularStyle.copyWith(fontWeight: FontWeight.w600);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: ValueKey('legal-document-table-scroll-$index'),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > minimumWidth
                  ? constraints.maxWidth
                  : minimumWidth,
            ),
            child: Table(
              key: ValueKey('legal-document-table-$index'),
              border: TableBorder.all(
                color: AppColors.white.withValues(alpha: 0.35),
                width: 0.7,
              ),
              columnWidths: columnCount == 3
                  ? const {
                      0: FixedColumnWidth(180),
                      1: FlexColumnWidth(1.15),
                      2: FlexColumnWidth(),
                    }
                  : const {0: FixedColumnWidth(210), 1: FlexColumnWidth()},
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: [
                for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                  TableRow(
                    decoration: rowIndex == 0
                        ? BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.12),
                          )
                        : null,
                    children: [
                      for (final cell in rows[rowIndex])
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            cell,
                            style: rowIndex == 0 ? headerStyle : regularStyle,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LinkedText extends StatefulWidget {
  const _LinkedText({super.key, required this.text, required this.links});

  final String text;
  final List<({String text, String url})> links;

  @override
  State<_LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<_LinkedText> with LotusInlineLinks<_LinkedText> {
  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.inverseUrbanistRegular14.copyWith(
      height: 1.08,
    );

    if (widget.links.isEmpty) {
      return Text(widget.text, style: style);
    }

    final children = <InlineSpan>[];
    var remainingText = widget.text;

    for (final link in widget.links) {
      if (!remainingText.contains(link.text)) continue;
      final parts = remainingText.split(link.text);
      children.add(TextSpan(text: parts[0]));
      children.add(
        linkSpan(
          id: link.url,
          text: link.text,
          style: AppTypography.link.copyWith(
            color: style.color,
            decorationColor: AppColors.white.withValues(alpha: 0.85),
          ),
          onTap: () => launchUrl(
            Uri.parse(link.url),
            mode: LaunchMode.externalApplication,
          ),
        ),
      );
      remainingText = parts.length > 1 ? parts.sublist(1).join(link.text) : '';
    }
    children.add(TextSpan(text: remainingText));

    return RichText(
      text: TextSpan(style: style, children: children),
    );
  }
}
