import "package:flutter_bloc/flutter_bloc.dart";
import "package:catat_keuangan/module/synchronization/synchronization_event.dart";
import "package:catat_keuangan/module/synchronization/synchronization_state.dart";
import "package:catat_keuangan/service/background_service.dart";

class SynchronizationBloc
    extends Bloc<SynchronizationEvent, SynchronizationState> {
  SynchronizationBloc() : super(SynchronizationInitial()) {
    on<SynchronizationLoad>((event, emit) async {
      await BackgroundService.checkVersion(synchronizationBloc: this);

      emit(SynchronizationSuccess());
    });

    on<SynchronizationUpdateMessage>((event, emit) async {
      emit(SynchronizationMessageChanged(message: event.message));
    });

    on<SynchronizationUpdateProgress>((event, emit) async {
      emit(
        SynchronizationProgressChanged(
          progress: event.progress,
          total: event.total,
        ),
      );
    });
  }
}
