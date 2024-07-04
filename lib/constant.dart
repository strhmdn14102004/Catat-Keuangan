// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class Parameter {
  static const bool API_PRINT_LOGGING_ENABLED = true;
  static const String SALT = "1234567890";
}

class ApiUrl {
  static String MAIN_BASE = "https://posdemo.sisapp.com:8443/big-part/api/v1/";
  static String SECONDARY_BASE =
      "https://posdemo.sisapp.com:8443/big-part/api/v1/";
  static String VERSION = "check-version";
  static String DESTINATION = "destinations";
  static String LOT_PROCESS = "lot-processes";
  static String CASE = "cases";
  static String SEQUENCE = "sequences";

}

enum SharedPreferenceKey {
  SESSION_ID,
  LAST_SYNC,
}

enum VersionKey {
  VERSION("VERSION"),
  DESTINATION("DESTINATION"),
  LOT_PROCESS("LOT_PROCESS"),
  CASE("CASE"),
  Sequence("Sequence");

  final String key;

  const VersionKey(this.key);
}

enum ScannerWordCase {
  UPPER_CASE,
  LOWER_CASE,
  NORMAL_CASE;

  String spell() {
    if (this == ScannerWordCase.NORMAL_CASE) {
      return "Normal Case";
    } else if (this == ScannerWordCase.UPPER_CASE) {
      return "UPPER CASE";
    } else {
      return "lower case";
    }
  }
}

enum activityHistory {
  SIGN_IN,
  SIGN_OUT,
  START_ACTIVITY,
  STOP_ACTIVITY,
}
