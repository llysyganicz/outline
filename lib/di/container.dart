import 'package:kiwi/kiwi.dart';

import '../notifiers/editor_notifier.dart';
import '../services/file_service.dart';
import '../services/preferences_service.dart';

/// Sets up the dependency injection container.
///
/// Must be called once from [main] before [runApp]. All services and notifiers
/// are registered here as singletons and resolved by widgets via
/// [KiwiContainer.resolve].
void setupDependencies() {
  final container = KiwiContainer();

  // -- Services ----------------------------------------------------------

  container.registerSingleton((c) => PreferencesService());
  container.registerSingleton((c) => FileService());

  // -- Notifiers ---------------------------------------------------------

  container.registerSingleton(
    (c) => EditorNotifier(
      c<PreferencesService>(),
      c<FileService>(),
    ),
  );
}
