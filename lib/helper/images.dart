import "package:catat_keuangan/helper/navigators.dart";
import "package:flutter/material.dart";

class Images {
  static Brightness brightness() {
    if (Navigators.navigatorState.currentContext != null) {
      return MediaQuery.of(Navigators.navigatorState.currentContext!).platformBrightness;
    }

    return Brightness.light;
  }

  static bool darkMode() {
    return brightness() == Brightness.dark;
  }

  static String catat_keuangan() {
    if (darkMode()) {
      return "assets/image/dino_express_black.png";
    } else {
      return "assets/image/dino_express_white.png";
    }
  }

  static String catat_keuanganInverse() {
    if (darkMode()) {
      return "assets/image/dino_express_white.png";
    } else {
      return "assets/image/dino_express_black.png";
    }
  }
}
