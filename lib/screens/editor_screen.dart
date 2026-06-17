import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';

/// Placeholder editor screen.
///
/// Currently displays only the app name.  Will be expanded in Phase 2 with
/// the two-panel file-tree + editor layout.
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const material.Scaffold(
      body: material.Center(
        child: Text('Outline'),
      ),
    );
  }
}
