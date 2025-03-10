class LogUtils {
  static void info(String message) {
    print('I/flutter: $message');
  }

  static void error(String message, [dynamic error]) {
    print('E/flutter: $message ${error != null ? '- $error' : ''}');
  }

  static void shipData(String mmsi, {String? name, String? type, String? action}) {
    print('I/flutter: Ship[$mmsi] ${name != null ? 'name=$name' : ''} ${type != null ? 'type=$type' : ''} ${action != null ? 'action=$action' : ''}');
  }
}