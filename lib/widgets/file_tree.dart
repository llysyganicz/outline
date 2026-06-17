import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../services/file_service.dart';

/// A stateless widget that renders a [TreeView] populated from a root
/// directory path.
///
/// Directories show expand/collapse chevrons; `.md` file leaves invoke
/// [onFileTapped] when pressed. The file tree is built synchronously from
/// [FileService.listDirectory] on every build — acceptable because directory
/// listings are fast on local filesystems and the tree is rebuilt only when
/// the root path or selected file changes.
class FileTree extends StatelessWidget {
    const FileTree({
    super.key,
    required this.fileService,
    required this.rootPath,
    required this.selectedFilePath,
    required this.onFileTapped,
  });

  /// The [FileService] used to scan the filesystem.
  final FileService fileService;

  /// The absolute path of the notes root directory to display.
  final String rootPath;

  /// A [ValueListenable] that tracks the currently-selected file path.
  ///
  /// Used to set the initial selection state of the [TreeView] so the
  /// active item is highlighted.
  final ValueListenable<String?> selectedFilePath;

  /// Called when the user taps a `.md` file leaf in the tree.
  final void Function(String filePath) onFileTapped;

  @override
  Widget build(BuildContext context) {
    final entries = fileService.listDirectory(rootPath);

    // Rebuild items whenever selectedFilePath changes so the TreeView
    // reflects the current selection highlight.
    return ValueListenableBuilder<String?>(
      valueListenable: selectedFilePath,
      builder: (context, selectedPath, _) {
        final items = _buildItems(entries, selectedPath);
        return TreeView(
          selectionMode: TreeViewSelectionMode.single,
          items: items,
          onItemInvoked: (item, reason) async {
            if (reason == TreeViewItemInvokeReason.pressed) {
              final path = item.value as String;
              if (path.toLowerCase().endsWith('.md')) {
                onFileTapped(path);
              }
            }
          },
        );
      },
    );
  }

  List<TreeViewItem> _buildItems(
    List<FileSystemEntry> entries,
    String? selectedPath,
  ) {
    return entries.map((entry) {
      if (entry.isDirectory) {
        return TreeViewItem(
          key: ValueKey(entry.path),
          content: Text(entry.name),
          leading: const Icon(FluentIcons.folder, size: 16),
          value: entry.path,
          expanded: false,
          children: _buildItems(entry.children, selectedPath),
        );
      } else {
        return TreeViewItem(
          key: ValueKey(entry.path),
          content: Text(entry.name),
          value: entry.path,
          selected: entry.path == selectedPath,
        );
      }
    }).toList();
  }
}
