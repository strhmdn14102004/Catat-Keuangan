import "dart:io";

import "package:catat_keuangan/api/custom_http_overrides.dart";
import "package:catat_keuangan/firebase_options.dart";
import "package:catat_keuangan/helper/app_colors.dart";
import "package:catat_keuangan/helper/dimensions.dart";
import "package:catat_keuangan/helper/navigators.dart";
import "package:catat_keuangan/helper/preferences.dart";
import "package:catat_keuangan/module/home/home_bloc.dart";
import "package:catat_keuangan/module/home/home_page.dart";
import "package:catat_keuangan/module/synchronization/synchronization_bloc.dart";
import "package:catat_keuangan/service/background_service.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:get/get_navigation/src/root/get_material_app.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:loader_overlay/loader_overlay.dart";
import "package:lottie/lottie.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  HttpOverrides.global = CustomHttpOverrides();
  initializeDateFormatting();
  await Preferences.getInstance().init();
  await BackgroundService.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(App());
}

class App extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(_getPreferredOrientations(context));
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => SynchronizationBloc()),
        BlocProvider(create: (BuildContext context) => HomeBloc()),
      ],
      child: GlobalLoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/loading_clock.json",
                frameRate: FrameRate(60),
                width: Dimensions.size100 * 2,
                repeat: true,
              ),
              Text(
                "Memuat...",
                style: TextStyle(
                  fontSize: Dimensions.text20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        overlayColor: Colors.black,
        overlayOpacity: 0.8,
        child: DismissKeyboard(
          child: GetMaterialApp(
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            title: "Catat Keuangan",
            navigatorKey: Navigators.navigatorState,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: "Barlow",
              colorScheme: AppColors.lightColorScheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: "Barlow",
              colorScheme: AppColors.darkColorScheme,
            ),
            themeMode: ThemeMode.system,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child ?? Container(),
              );
            },
            home: const HomePage(),
          ),
        ),
      ),
    );
  }

  List<DeviceOrientation> _getPreferredOrientations(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool useLandscape = shortestSide > 600;
    return useLandscape
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
