import 'dart:io';

import 'package:flutter/foundation.dart';

/// A single entry in a file-system tree listing.
///
/// Directories carry a non-empty [children] list (recursively populated);
/// files have no children.
class FileSystemEntry {
  final String path;
  final String name;
  final bool isDirectory;
  final List<FileSystemEntry> children;

  FileSystemEntry({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.children = const [],
  });
}

/// Provides the filesystem operations needed by this slice:
///
///   * List a directory's contents (`.md` files and subdirectories only).
///   * Read a file as a string.
///   * Write a string to a file.
class FileService {
  /// Recursively lists all `.md` files and subdirectories under [dirPath].
  ///
  /// Entries are sorted: directories before files, both groups alphabetically
  /// by name (case-insensitive). Non-`.md` files are excluded from the result.
  List<FileSystemEntry> listDirectory(String dirPath) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return [];

      final entities = dir.listSync(recursive: false);

      // Keep directories and markdown files only.
      final filtered = <FileSystemEntity>[];
      for (final entity in entities) {
        if (entity is Directory) {
          filtered.add(entity);
        } else if (entity is File &&
            entity.path.toLowerCase().endsWith('.md')) {
          filtered.add(entity);
        }
      }

      // Sort: directories first, then files; both groups alphabetically.
      filtered.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
        final aName = a.path.split('/').last.toLowerCase();
        final bName = b.path.split('/').last.toLowerCase();
        return aName.compareTo(bName);
      });

      final entries = <FileSystemEntry>[];
      for (final entity in filtered) {
        final name = entity.path.split('/').last;
        if (entity is Directory) {
          entries.add(FileSystemEntry(
            path: entity.path,
            name: name,
            isDirectory: true,
            children: listDirectory(entity.path),
          ));
        } else {
          entries.add(FileSystemEntry(
            path: entity.path,
            name: name,
            isDirectory: false,
          ));
        }
      }

      return entries;
    } catch (e, st) {
      debugPrint('FileService.listDirectory failed for $dirPath: $e\n$st');
      return [];
    }
  }

  /// Reads the file at [filePath] and returns its contents as a string.
  /// Returns `null` if the file cannot be read (e.g. permission denied).
  Future<String?> readFile(String filePath) async {
    try {
      return await File(filePath).readAsString();
    } catch (e, st) {
      debugPrint('FileService.readFile failed for $filePath: $e\n$st');
      return null;
    }
  }

  /// Writes [content] to the file at [filePath], overwriting any existing
  /// content.
  Future<void> writeFile(String filePath, String content) async {
    try {
      await File(filePath).writeAsString(content);
    } catch (e, st) {
      debugPrint('FileService.writeFile failed for $filePath: $e\n$st');
      // Silently ignore write failures — the next auto-save or manual
      // save will retry. A persistent error is a filesystem issue the
      // user needs to resolve outside Outline.
    }
  }
}
