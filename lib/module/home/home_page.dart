import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart"; // Tambahkan import ini
import "package:catat_keuangan/constant.dart";
import "package:catat_keuangan/helper/app_colors.dart";
import "package:catat_keuangan/helper/dimensions.dart";
import "package:catat_keuangan/helper/preferences.dart";

import "package:catat_keuangan/module/home/home_bloc.dart";
import "package:catat_keuangan/module/home/home_state.dart";
import "package:catat_keuangan/module/synchronization/synchronization_bloc.dart";
import "package:catat_keuangan/module/synchronization/synchronization_page.dart";
import "package:catat_keuangan/overlay/overlays.dart";
import "package:catat_keuangan/service/background_service.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime? currentBackPressTime;
  String lastSyncTime = "Just now"; // Variable to hold the last sync time
  bool isLoading = false; // Variable to show loading state

  @override
  void initState() {
    super.initState();
    refresh();
    WidgetsBinding.instance.addObserver(this);
  }

  void refresh() async {
    setState(() {
      isLoading = true;
    });
    final synchronizationBloc = BlocProvider.of<SynchronizationBloc>(context);
    await BackgroundService.checkVersion(
      synchronizationBloc: synchronizationBloc,
    );
    lastSyncTime = await Preferences.getInstance()
            .getString(SharedPreferenceKey.LAST_SYNC) ??
        DateFormat("dd MMMM yyyy HH:mm:ss", "id_ID").format(DateTime.now());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) async {},
        ),
      ],
      child: PopScope(
        onPopInvoked: (didPop) {
          if (didPop) {
            onBackButton();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: AppColors.brightnessInverse(),
          ),
          child: Scaffold(
            body: body(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  Future<bool> onBackButton() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
        ),
      );

      return Future.value(false);
    }

    SystemNavigator.pop();
    return Future.value(true);
  }

  Widget body() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "WELCOME",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Dimensions.size25),
            isLoading ? const CircularProgressIndicator() : syncButton(),
            const SizedBox(height: 32),
            Column(
              children: [
                Container(
                  width: 380,
                  height: 110,
                  child: OutlinedButton(
                    onPressed: () {
                     
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ), // Outline color and width
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ), // Text and icon color
                      backgroundColor:
                          Colors.transparent, // Transparent background
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // Remove rounded corners
                      ),
                      minimumSize: const Size(
                        300,
                        60,
                      ), // Set the minimum size for the button
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.green,
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "PROCESS",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 380,
                  height: 110,
                  child: OutlinedButton(
                    onPressed: () {
                      Overlays.comming(message: "");
                      // Navigate to History Page
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => HistoryPage(),
                      //   ),
                      // );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ), // Outline color and width
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ), // Text and icon color
                      backgroundColor:
                          Colors.transparent, // Transparent background
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // Remove rounded corners
                      ),
                      minimumSize: const Size(
                        300,
                        60,
                      ), // Set the minimum size for the button
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.manage_history_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "HISTORY",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget syncButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SynchronizationPage(),
          ),
        );
        // refresh();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Last Sync"),
              Text(
                lastSyncTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(width: Dimensions.size15),
          const Icon(Icons.sync),
          const Text(
            "Sync Now",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
