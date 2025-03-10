class WeatherData {
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;
  final DateTime timestamp;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return WeatherData(
      location: data['lokasi'] ?? 'Surabaya Port',
      temperature: _parseDouble(data['suhu']),
      humidity: _parseDouble(data['kelembaban']),
      windSpeed: _parseDouble(data['kecepatan_angin']),
      windDirection: data['arah_angin'] ?? 'N/A',
      pressure: _parseDouble(data['tekanan_udara']),
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}