import 'package:fluent_ui/fluent_ui.dart';
import 'package:kiwi/kiwi.dart';

import '../notifiers/editor_notifier.dart';
import '../widgets/file_tree.dart';
import '../widgets/note_editor.dart';

/// Two-panel layout: file tree (left) + editor or preview (right).
/// All state lives in [EditorNotifier]; this widget is stateless.
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
          return NoteEditor(
            controller: _notifier.codeController,
            onChanged: _notifier.onEditorChanged,
          );
        },
      ),
    );
  }
}
