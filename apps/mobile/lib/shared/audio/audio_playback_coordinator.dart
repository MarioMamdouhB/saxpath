typedef AudioPlaybackInterruptHandler = Future<void> Function();

class AudioPlaybackCoordinator {
  AudioPlaybackCoordinator._();

  static final AudioPlaybackCoordinator instance =
      AudioPlaybackCoordinator._();

  Object? _activeOwner;
  AudioPlaybackInterruptHandler? _activeInterruptHandler;

  bool isActiveOwner(Object owner) => identical(_activeOwner, owner);

  Future<void> activate({
    required Object owner,
    required AudioPlaybackInterruptHandler onInterrupt,
  }) async {
    final previousOwner = _activeOwner;
    final previousInterruptHandler = _activeInterruptHandler;

    _activeOwner = owner;
    _activeInterruptHandler = onInterrupt;

    if (previousOwner != null && !identical(previousOwner, owner)) {
      await previousInterruptHandler?.call();
    }
  }

  void release(Object owner) {
    if (!identical(_activeOwner, owner)) {
      return;
    }

    _activeOwner = null;
    _activeInterruptHandler = null;
  }

  void resetForTest() {
    _activeOwner = null;
    _activeInterruptHandler = null;
  }
}
