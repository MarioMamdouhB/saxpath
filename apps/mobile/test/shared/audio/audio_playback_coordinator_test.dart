import 'package:flutter_test/flutter_test.dart';
import 'package:saxpath_mobile/shared/audio/audio_playback_coordinator.dart';

void main() {
  final coordinator = AudioPlaybackCoordinator.instance;

  setUp(() {
    coordinator.resetForTest();
  });

  tearDown(() {
    coordinator.resetForTest();
  });

  test('first activation claims ownership without interruption', () async {
    final owner = Object();
    var interrupted = false;

    await coordinator.activate(
      owner: owner,
      onInterrupt: () async {
        interrupted = true;
      },
    );

    expect(coordinator.isActiveOwner(owner), isTrue);
    expect(interrupted, isFalse);
  });

  test('activating a new owner interrupts the previous owner once', () async {
    final firstOwner = Object();
    final secondOwner = Object();
    var firstInterruptCount = 0;

    await coordinator.activate(
      owner: firstOwner,
      onInterrupt: () async {
        firstInterruptCount += 1;
      },
    );

    await coordinator.activate(
      owner: secondOwner,
      onInterrupt: () async {},
    );

    expect(firstInterruptCount, 1);
    expect(coordinator.isActiveOwner(firstOwner), isFalse);
    expect(coordinator.isActiveOwner(secondOwner), isTrue);
  });

  test('release clears ownership only for the active owner', () async {
    final firstOwner = Object();
    final secondOwner = Object();

    await coordinator.activate(
      owner: firstOwner,
      onInterrupt: () async {},
    );
    await coordinator.activate(
      owner: secondOwner,
      onInterrupt: () async {},
    );

    coordinator.release(firstOwner);
    expect(coordinator.isActiveOwner(secondOwner), isTrue);

    coordinator.release(secondOwner);
    expect(coordinator.isActiveOwner(secondOwner), isFalse);
  });
}
