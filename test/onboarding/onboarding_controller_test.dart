import 'package:flutter_test/flutter_test.dart';
import 'package:kgl_time/app/app_initialization.dart';
import 'package:kgl_time/onboarding/onboarding_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../support/memory_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStorage storage;
  late OnboardingController controller;

  setUp(() {
    storage = MemoryStorage();
    controller = OnboardingController(storage: storage.keyValueStorage);
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'test.kgl_time',
      version: '0.4.1',
      buildNumber: '19',
      buildSignature: '',
    );
  });

  tearDown(() async => storage.close());

  test('missing completion flag does not onboard existing installations', () async {
    expect(await controller.isPending(), isFalse);
    expect(await storage.keyValueStorage.get<bool>(OnboardingController.completedKey), isNull);
  });

  test('pending onboarding remains pending until acknowledged', () async {
    await storage.keyValueStorage.set<bool>(OnboardingController.completedKey, false);
    expect(await controller.isPending(), isTrue);
    expect(await controller.isPending(), isTrue);
    await controller.acknowledge();
    expect(await storage.keyValueStorage.get<bool>(OnboardingController.completedKey), isTrue);
    expect(await controller.isPending(), isFalse);
  });

  test('first-run initialization persists pending onboarding before the UI launches', () async {
    final InitialAppData data = await initializeApp(storage: storage);
    expect(data.keyValues['isFirstRun'], isTrue);
    expect(data.keyValues[OnboardingController.completedKey], isFalse);
    expect(await storage.keyValueStorage.get<bool>('isFirstRun'), isFalse);
    expect(await controller.isPending(), isTrue);
  });

  test('interrupted first startup retries onboarding despite isFirstRun being false', () async {
    await initializeApp(storage: storage);
    final InitialAppData nextLaunch = await initializeApp(storage: storage);
    expect(nextLaunch.keyValues['isFirstRun'], isFalse);
    expect(nextLaunch.categories, hasLength(3));
    expect(await controller.isPending(), isTrue);
  });

  test('initialization does not enroll existing users in onboarding', () async {
    await storage.keyValueStorage.set<bool>('isFirstRun', false);
    final InitialAppData data = await initializeApp(storage: storage);
    expect(data.keyValues.containsKey(OnboardingController.completedKey), isFalse);
    expect(await controller.isPending(), isFalse);
  });

  test('acknowledged onboarding stays completed after another initialization', () async {
    await initializeApp(storage: storage);
    await controller.acknowledge();
    await initializeApp(storage: storage);
    expect(await controller.isPending(), isFalse);
  });
}
