import 'package:kiwi/kiwi.dart';

/// Sets up the dependency injection container.
///
/// Must be called once from [main] before [runApp]. All services and notifiers
/// are registered here as singletons and resolved by widgets via
/// [KiwiContainer.resolve].
void setupDependencies() {
  // Services and notifiers will be registered incrementally as each phase
  // lands.  The container must exist before FluentApp is created, even if it
  // carries no registrations yet.
  KiwiContainer();
}
