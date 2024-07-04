abstract class SynchronizationEvent {}

class SynchronizationLoad extends SynchronizationEvent {}

class SynchronizationUpdateMessage extends SynchronizationEvent {
  final String message;

  SynchronizationUpdateMessage({
    required this.message,
  });
}

class SynchronizationUpdateProgress extends SynchronizationEvent {
  final int progress;
  final int total;

  SynchronizationUpdateProgress({
    required this.progress,
    required this.total,
  });
}

