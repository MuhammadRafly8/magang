class ShipLogger {
  static const int _logInterval = 1000; // 1 detik
  static DateTime _lastLogTime = DateTime.now();
  static int _batchCount = 0;

  static void logShipData(String mmsi, {String? name, String? type}) {
    _batchCount++;
    
    final now = DateTime.now();
    if (now.difference(_lastLogTime).inMilliseconds >= _logInterval) {
      print('Ship updates in last second: $_batchCount ships');
      print('Last ship: MMSI=$mmsi, Name=$name, Type=$type');
      _batchCount = 0;
      _lastLogTime = now;
    }
  }
}