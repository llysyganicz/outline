import 'package:fluent_ui/fluent_ui.dart';
import 'package:kiwi/kiwi.dart';

import '../notifiers/editor_notifier.dart';
import '../widgets/file_tree.dart';

/// Main editor screen with a two-panel layout.
///
/// Layout:
/// ```
/// ┌─ CommandBar (Change folder) ──────────────────────────────────┐
/// ├──────────┬────────────────────────────────────────────────────┤
/// │ FileTree │  Right panel: placeholder (Phase 3 → NoteEditor)  │
/// │ (260px)  │  or "Select a note" when no file is active         │
/// └──────────┴────────────────────────────────────────────────────┘
/// ```
///
/// All state lives in [EditorNotifier]; this widget is a pure
/// [StatelessWidget] with zero business logic.
class EditorScreen extends StatelessWidget {
  EditorScreen({super.key})
      : _notifier = KiwiContainer().resolve<EditorNotifier>();

  final EditorNotifier _notifier;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: Row(
              children: [
                _buildFileTreePanel(),
                _buildDivider(context),
                _buildEditorPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Toolbar -----------------------------------------------------------

  Widget _buildToolbar() {
    return CommandBar(
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FluentIcons.folder_open, size: 16),
          label: const Text('Change folder'),
          onPressed: () => _notifier.changeRootDirectory(),
        ),
      ],
    );
  }

  // -- File tree panel (left) -------------------------------------------

  Widget _buildFileTreePanel() {
    return SizedBox(
      width: 260,
      height: double.infinity,
      child: ValueListenableBuilder<String?>(
        valueListenable: _notifier.rootDirectory,
        builder: (context, root, _) {
          if (root == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Select a folder to get started'),
              ),
            );
          }
          return FileTree(
            rootPath: root,
            selectedFilePath: _notifier.selectedFilePath,
            onFileTapped: _notifier.selectFile,
          );
        },
      ),
    );
  }

  // -- Vertical divider --------------------------------------------------

  Widget _buildDivider(BuildContext context) {
    return const Divider(
      direction: Axis.vertical,
    );
  }

  // -- Editor panel (right) ---------------------------------------------

  Widget _buildEditorPanel() {
    return Expanded(
      child: ValueListenableBuilder<String?>(
        valueListenable: _notifier.selectedFilePath,
        builder: (context, path, _) {
          if (path == null) {
            return const Center(child: Text('Select a note'));
          }
          // Placeholder — replaced with NoteEditor in Phase 3.
          return const Center(child: Text('Editor (Phase 3)'));
        },
      ),
    );
  }
}
