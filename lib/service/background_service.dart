// ignore_for_file: constant_identifier_names, avoid_print, empty_catches

import "dart:ui";

import "package:catat_keuangan/helper/preferences.dart";
import "package:catat_keuangan/module/synchronization/synchronization_bloc.dart";
import "package:catat_keuangan/module/synchronization/synchronization_event.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:jiffy/jiffy.dart";
import "package:workmanager/workmanager.dart";

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Toyota Big Part native called background task: $task");
    await Preferences.getInstance().init();
    DartPluginRegistrant.ensureInitialized();
    initializeDateFormatting();
    await Jiffy.setLocale("id");
    while (true) {
      try {
        await BackgroundService.checkVersion();
      } catch (ex) {}

      await Future.delayed(const Duration(minutes: 1));
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      "BackgroundServiceTask",
      "BackgroundServiceTask",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static Future<void> checkVersion({
    SynchronizationBloc? synchronizationBloc,
  }) async {
    try {
      if (synchronizationBloc != null) {
        synchronizationBloc
            .add(SynchronizationUpdateMessage(message: "Checking version..."));
        // await fetchAndUpdateDestination(synchronizationBloc, 0);
        // await fetchAndUpdateLotProcess(synchronizationBloc, 0);
        // await fetchAndUpdateCase(synchronizationBloc, 0);
        // await fetchAndUpdateProcess(synchronizationBloc, 0);
        synchronizationBloc.add(
          SynchronizationUpdateMessage(message: "Data selesai di sinkronisasi"),
        );
      }
    } catch (e) {
      if (synchronizationBloc != null) {
        synchronizationBloc.add(SynchronizationUpdateMessage(message: "$e"));
      }
    }
  }

//   static Future<void> fetchAndUpdateDestination(
//     SynchronizationBloc? synchronizationBloc,
//     int version,
//   ) async {
//     try {
//       if (synchronizationBloc != null) {
//         synchronizationBloc.add(
//           SynchronizationUpdateMessage(message: "Mengunduh data destinasi..."),
//         );

//         final response = await ApiManager().destination(version);
//         final destinationsResponse =
//             DestinationsResponse.fromJson(response.data);
//         DestinationDao.insertOrUpdate(
//           versionKey: VersionKey.DESTINATION,
//           destinationResponse: destinationsResponse,
//           lastVersion: version.toString(),
//         );
//         synchronizationBloc
//             .add(SynchronizationUpdateProgress(progress: 1, total: 4));
//       }
//     } catch (e) {
//       throw Exception("Gagal untuk update destinasi: $e");
//     }
//   }

//   static Future<void> fetchAndUpdateLotProcess(
//     SynchronizationBloc? synchronizationBloc,
//     int version,
//   ) async {
//     try {
//       if (synchronizationBloc != null) {
//         synchronizationBloc.add(
//           SynchronizationUpdateMessage(message: "Mengunduh data lot proses..."),
//         );

//         final response = await ApiManager().lotProcess(version, 0);
//         final lotProcessResponse = LotProcessResponse.fromJson(response.data);
//         LotProcessDao.insertOrUpdate(
//           versionKey: VersionKey.LOT_PROCESS,
//           lotProcessResponse: lotProcessResponse,
//           lastVersion: version.toString(),
//         );
//         synchronizationBloc
//             .add(SynchronizationUpdateProgress(progress: 2, total: 4));
//       }
//     } catch (e) {
//       throw Exception("Gagal untuk update lot process: $e");
//     }
//   }

//   static Future<void> fetchAndUpdateCase(
//     SynchronizationBloc? synchronizationBloc,
//     int version,
//   ) async {
//     try {
//       if (synchronizationBloc != null) {
//         synchronizationBloc.add(
//           SynchronizationUpdateMessage(message: "Mengunduh data case..."),
//         );

//         final response = await ApiManager().getCase(version, 0);
//         final caseResponse = CaseResponse.fromJson(response.data);
//         CaseDao.insertOrUpdate(
//           versionKey: VersionKey.CASE,
//           caseResponse: caseResponse,
//           lastVersion: version.toString(),
//         );
//         synchronizationBloc
//             .add(SynchronizationUpdateProgress(progress: 3, total: 4));
//       }
//     } catch (e) {
//       throw Exception("Gagal untuk update case: $e");
//     }
//   }

//   static Future<void> fetchAndUpdateProcess(
//     SynchronizationBloc? synchronizationBloc,
//     int version,
//   ) async {
//     try {
//       if (synchronizationBloc != null) {
//         synchronizationBloc.add(
//           SynchronizationUpdateMessage(message: "Mengunduh data proses..."),
//         );

//         final response = await ApiManager().getProcess(version, 0);
//         final processResponse = ProcessResponse.fromJson(response.data);
//         ProcessDao.insertOrUpdate(
//           versionKey: VersionKey.Sequence,
//           processResponse: processResponse,
//           lastVersion: version.toString(),
//         );
//         synchronizationBloc
//             .add(SynchronizationUpdateProgress(progress: 4, total: 4));
//       }
//     } catch (e) {
//       throw Exception("Gagal untuk update proses: $e");
//     }
//   }
// }
}
