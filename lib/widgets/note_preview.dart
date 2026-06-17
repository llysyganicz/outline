import 'package:fluent_ui/fluent_ui.dart' hide Typography;
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../theme/gruvbox_theme.dart';
import '../utils/frontmatter.dart';

/// Renders the body of a markdown note as a scrollable preview.
///
/// YAML frontmatter is stripped before rendering. Styles are derived from the
/// current Gruvbox theme so the preview visually matches the editor.
class NotePreview extends StatelessWidget {
  const NotePreview({super.key, required this.content});

  /// Raw file content, which may include a YAML frontmatter block.
  final String content;

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;
    final body = stripFrontmatter(content);

    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            child: MarkdownBody(
              data: body,
              styleSheet: _buildStyleSheet(brightness),
              selectable: true,
              fitContent: false,
            ),
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fg = isDark ? GruvboxTheme.darkFg : GruvboxTheme.lightFg;
    final bg = isDark ? GruvboxTheme.darkBg : GruvboxTheme.lightBg;
    final accent = GruvboxTheme.aqua;
    final codeBg = isDark ? const Color(0xFF3c3836) : const Color(0xFFebdbb2);

    final base = TextStyle(color: fg, fontSize: 14);

    return MarkdownStyleSheet(
      p: base,
      h1: base.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      h2: base.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
      h3: base.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      h4: base.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      h5: base.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      h6: base.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      strong: base.copyWith(fontWeight: FontWeight.bold),
      em: base.copyWith(fontStyle: FontStyle.italic),
      code: base.copyWith(
        backgroundColor: codeBg,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      blockquote: base.copyWith(fontStyle: FontStyle.italic),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      blockquoteDecoration: BoxDecoration(
        color: codeBg,
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
      ),
      listBullet: base,
      a: base.copyWith(color: accent),
      tableHead: base.copyWith(fontWeight: FontWeight.bold),
      tableBody: base,
      tableBorder: TableBorder.all(color: fg.withAlpha(80)),
      tableCellsPadding: const EdgeInsets.all(8),
      tableCellsDecoration: BoxDecoration(color: bg),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: fg.withAlpha(80)),
        ),
      ),
    );
  }
}
