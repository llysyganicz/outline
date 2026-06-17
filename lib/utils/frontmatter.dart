/// Strips a YAML frontmatter block from the start of [content].
///
/// A frontmatter block is recognised when [content] begins with `---\n` and
/// contains a matching closing `\n---`. The returned string starts immediately
/// after the closing delimiter (skipping a single trailing newline). If no
/// valid frontmatter block is found, the original [content] is returned
/// unchanged.
String stripFrontmatter(String content) {
  if (!content.startsWith('---\n')) return content;

  const delimiterStart = '---\n'.length;
  final closing = content.indexOf('\n---', delimiterStart);
  if (closing == -1) return content;

  final afterClosing = closing + '\n---'.length;
  if (afterClosing < content.length && content[afterClosing] == '\n') {
    return content.substring(afterClosing + 1);
  }
  return content.substring(afterClosing);
}
