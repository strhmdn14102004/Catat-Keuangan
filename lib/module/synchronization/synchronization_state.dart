abstract class SynchronizationState {}

class SynchronizationInitial extends SynchronizationState {}

class SynchronizationMessageChanged extends SynchronizationState {
  final String message;

  SynchronizationMessageChanged({
    required this.message,
  });
}

class SynchronizationProgressChanged extends SynchronizationState {
  final int progress;
  final int total;

  SynchronizationProgressChanged({
    required this.progress,
    required this.total,
  });
}

class SynchronizationSuccess extends SynchronizationState {}
