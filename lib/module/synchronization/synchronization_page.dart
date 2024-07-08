import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:catat_keuangan/helper/dimensions.dart";
import "package:catat_keuangan/helper/navigators.dart";
import "package:catat_keuangan/module/home/home_page.dart";
import "package:catat_keuangan/module/synchronization/synchronization_bloc.dart";
import "package:catat_keuangan/module/synchronization/synchronization_event.dart";
import "package:catat_keuangan/module/synchronization/synchronization_state.dart";

import "../../helper/app_colors.dart";

class SynchronizationPage extends StatefulWidget {
  const SynchronizationPage({Key? key}) : super(key: key);

  @override
  State<SynchronizationPage> createState() => SynchronizationPageState();
}

class SynchronizationPageState extends State<SynchronizationPage> {
  int progress = 0;
  int total = 0;
  String currentMessage = "";

  @override
  void initState() {
    super.initState();

    context.read<SynchronizationBloc>().add(SynchronizationLoad());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primary(),
        statusBarIconBrightness: AppColors.brightness(),
      ),
      child: Scaffold(
        body: BlocListener<SynchronizationBloc, SynchronizationState>(
          listener: (BuildContext context, SynchronizationState state) {
            if (state is SynchronizationMessageChanged) {
              setState(() {
                currentMessage = state.message;
              });
            } else if (state is SynchronizationProgressChanged) {
              setState(() {
                progress = state.progress;
                total = state.total;
              });
            } else if (state is SynchronizationSuccess) {
              // Navigators.pushAndRemoveAll(
              //   context,
              //    HomePage(),
              // );
            }
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: content(),
          ),
        ),
      ),
    );
  }

  Widget content() {
    if (total == 0) {
      return Center(
        child: Text(
          "Mohon tunggu data sedang dimuat...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Dimensions.text14,
          ),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "${(progress / total * 100).toInt()} %",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.text20,
                ),
              ),
              SizedBox(
                height: Dimensions.size50 * 4,
                width: Dimensions.size50 * 4,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: progress / total,
                  ),
                  builder: (BuildContext context, double value, Widget? child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: Dimensions.size10,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: Dimensions.size30,
          ),
          Text(
            currentMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.text16,
            ),
          ),
        ],
      );
    }
  }
}
