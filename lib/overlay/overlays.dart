import "package:catat_keuangan/helper/navigators.dart";
import "package:catat_keuangan/overlay/cooming_soon.dart";
import "package:catat_keuangan/overlay/error_overlay.dart";
import "package:catat_keuangan/overlay/success_overlay.dart";
import "package:flutter/material.dart";

class Overlays {
  static Future<void> error({
    required String message,
  }) async {
    if (Navigators.navigatorState.currentContext != null) {
      await Navigator.of(Navigators.navigatorState.currentContext!).push(
        ErrorOverlay(
          message: message,
        ),
      );
    }
  }

 
  static Future<void> comming({
    required String message,
  }) async {
    if (Navigators.navigatorState.currentContext != null) {
      await Navigator.of(Navigators.navigatorState.currentContext!).push(
        CommingSoonOverlay(
          message: message,
        ),
      );
    }
  }

  static Future<void> success({
    required String message,
  }) async {
    if (Navigators.navigatorState.currentContext != null) {
      await Navigator.of(Navigators.navigatorState.currentContext!).push(
        SuccessOverlay(
          message: message,
        ),
      );
    }
  }
}
