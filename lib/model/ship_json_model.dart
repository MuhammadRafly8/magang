class ShipJsonData {
  final String mmsi;
  final String? name;
  final String? type;

  ShipJsonData({
    required this.mmsi,
    this.name,
    this.type,
  });

  factory ShipJsonData.fromJson(Map<String, dynamic> json) {
    return ShipJsonData(
      mmsi: json['MMSI'].toString(),
      name: json['NAME'],
      type: json['TYPENAME'],
    );
  }
}