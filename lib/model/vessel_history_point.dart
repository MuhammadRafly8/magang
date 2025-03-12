import 'package:latlong2/latlong.dart';
class VesselHistoryPoint {
  final double lat;
  final double lon;
  final double cog;
  final double sog;
  final int hdg;
  final int navstatus;
  final String portOrigin;
  final DateTime createdAt;

  VesselHistoryPoint({
    required this.lat,
    required this.lon,
    required this.cog,
    required this.sog,
    required this.hdg,
    required this.navstatus,
    required this.portOrigin,
    required this.createdAt,
  });

  factory VesselHistoryPoint.fromJson(Map<String, dynamic> json) {
    return VesselHistoryPoint(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      cog: double.parse(json['cog'].toString()),
      sog: double.parse(json['sog'].toString()),
      hdg: int.parse(json['hdg'].toString()),
      navstatus: int.parse(json['navstatus'].toString()),
      portOrigin: json['portOrigin'].toString(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to LatLng for map display
  LatLng toLatLng() {
    return LatLng(lat, lon);
  }

  // Get navigation status description
  String getNavStatusDescription() {
    switch (navstatus) {
      case 0: return 'Under way using engine';
      case 1: return 'At anchor';
      case 2: return 'Not under command';
      case 3: return 'Restricted maneuverability';
      case 4: return 'Constrained by her draught';
      case 5: return 'Moored';
      case 6: return 'Aground';
      case 7: return 'Engaged in fishing';
      case 8: return 'Under way sailing';
      case 9: return 'Reserved for future amendment';
      case 10: return 'Reserved for future amendment';
      case 11: return 'Power-driven vessel towing astern';
      case 12: return 'Power-driven vessel pushing ahead/towing alongside';
      case 13: return 'Reserved for future use';
      case 14: return 'AIS-SART (active), MOB-AIS, EPIRB-AIS';
      case 15: return 'Undefined';
      default: return 'Unknown';
    }
  }
}