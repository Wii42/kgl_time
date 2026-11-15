import '../persistent_storage/persistent_storage_interface.dart';

class OnboardingController {
  static const String completedKey = 'onboardingCompleted';

  final KeyValueStorage storage;

  const OnboardingController({required this.storage});

  /// Only new installations get an explicit pending flag during initialization.
  /// A missing flag belongs to an existing installation and must not trigger onboarding.
  Future<bool> isPending() async => await storage.get<bool>(completedKey) == false;

  Future<void> acknowledge() async {
    await storage.set<bool>(completedKey, true);
  }
}
