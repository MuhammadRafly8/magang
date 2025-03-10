import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class ShipData {
  String id;
  double latitude;
  double longitude;
  double speed;
  String? engineStatus; 
  String? name; 
  String? type; 
  String? navStatus; 
  double trueHeading;
  double cog;
  DateTime receivedOn;
  
  ShipData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.speed,
    this.engineStatus, 
    this.name, 
    this.type, 
    this.navStatus, 
    required this.trueHeading,
    required this.cog,
    required this.receivedOn,
  });
  
  Widget getIcon() {
    // Normalisasi tipe kapal dengan menghapus spasi dan mengubah ke lowercase
    final String normalizedType = type?.toLowerCase().replaceAll(' ', '') ?? '';
    
    // Tentukan tipe kapal untuk digunakan dalam path gambar
    String shipType = 'unknown';
    if (normalizedType.contains('cargo') || normalizedType.contains('general') || 
        normalizedType.contains('carrier') || normalizedType.contains('container')) {
      shipType = 'cargo';
    } else if (normalizedType.contains('cruise') || 
              normalizedType.contains('passenger') || 
              normalizedType.contains('ferry') ||
              normalizedType.contains('troop') || 
              normalizedType.contains('crew')) {
      shipType = 'cruise';
    } else if (normalizedType.contains('special') || 
              normalizedType.contains('other') ||
              normalizedType.contains('misc') ||
              normalizedType.contains('well stimulation') ||
              normalizedType.contains('pipe layer') ||
              normalizedType.contains('etc')) {
      shipType = 'special';
    } else if (normalizedType.contains('support') || 
              normalizedType.contains('service') ||
              normalizedType.contains('supply') ||
              normalizedType.contains('utility') ||
              normalizedType.contains('tug') ||
              normalizedType.contains('pilot') ||
              normalizedType.contains('tow')) {
      shipType = 'support';
    } else if (normalizedType.contains('tanker') || 
              normalizedType.contains('oil') ||
              normalizedType.contains('gas') ||
              normalizedType.contains('barge') ||
              normalizedType.contains('crude') ||
              normalizedType.contains('lng') ||
              normalizedType.contains('lpg')) {
      shipType = 'tanker';
    }
    
    // Cek status navigasi kapal
    int navStatusCode = -1;
    if (navStatus != null && navStatus != 'Unknown') {
      if (navStatus == 'At anchor') navStatusCode = 1;
      else if (navStatus == 'Moored') navStatusCode = 5;
    }
    
    // Debug untuk melihat nilai yang digunakan dalam penentuan ikon
    print('Kapal $id - Speed: $speed, NavStatus: $navStatus, NavStatusCode: $navStatusCode, TrueHeading: $trueHeading');
    
    // Kapal berlabuh (anchored)
    if (speed < 0.3 && navStatusCode == 1) {
      print('Kapal $id sedang berlabuh - menggunakan ikon diamAncored');
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Image.asset(
          'assets/icons/diamAncored/$shipType.png',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          isAntiAlias: true,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading diamAncored/$shipType.png: $error');
            return SvgPicture.asset('assets/icons/$shipType.svg', width: 18, height: 18);
          },
        ),
      );
    } 
    // Kapal diam tapi tidak berlabuh
    else if (speed < 0.3) {
      print('Kapal $id sedang diam - menggunakan ikon kapaldiam');
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Image.asset(
          'assets/icons/kapaldiam/$shipType.png',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          isAntiAlias: true,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading kapaldiam/$shipType.png: $error');
            return SvgPicture.asset('assets/icons/$shipType.svg', width: 18, height: 18);
          },
        ),
      );
    }
    // Kapal bergerak dengan arah tidak terdefinisi atau arah terdefinisi
    else {
      // Cek apakah heading terdefinisi dengan baik
      bool isHeadingDefined = trueHeading != 511 && trueHeading > 0;
      
      if (isHeadingDefined) {
        // Gunakan ikon SVG untuk kapal bergerak dengan heading terdefinisi
        print('Kapal $id bergerak dengan heading terdefinisi - menggunakan ikon SVG dengan rotasi $trueHeading derajat');
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Transform.rotate(
            angle: (trueHeading * (3.14159265359 / 180)), // Konversi derajat ke radian
            child: SvgPicture.asset(
              'assets/icons/$shipType.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        );
      } else {
        final rotationAngle = cog > 0 ? (cog * (3.14159265359 / 180)) : 0.0;
        print('Kapal $id bergerak dengan heading tidak terdefinisi - menggunakan ikon bergerakUndifined (belah ketupat) dengan rotasi $cog derajat');
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Transform.rotate(
            angle: rotationAngle,
            child: Image.asset(
              'assets/icons/bergerakUndifined/$shipType.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              isAntiAlias: true,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading bergerakUndifined/$shipType.png: $error');
                return SvgPicture.asset('assets/icons/$shipType.svg', width: 18, height: 18);
              },
            ),
          ),
        );
      }
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'mmsi': id,
      'lat': latitude,
      'lon': longitude,
      'sog': speed,
      'smi': engineStatus,
      'NAME': name,
      'TYPENAME': type,
      'navstatus': navStatus,
      'hdg': trueHeading,
      'cog': cog,
      'timestamp': receivedOn.toIso8601String(),
    };
  }
  
factory ShipData.fromJson(Map<String, dynamic> json) {
    try {
      // Extract nested data from WebSocket message
      final message = json['message'] as Map<String, dynamic>?;
      final data = message?['data'] as Map<String, dynamic>?;
      
      if (data == null || data['valid'] != true) {
        throw Exception('Invalid data structure or data not valid');
      }

      return ShipData(
        id: data['mmsi']?.toString() ?? '',
        latitude: data['lat']?.toDouble() ?? 0.0,
        longitude: data['lon']?.toDouble() ?? 0.0,
        speed: data['sog']?.toDouble() ?? 0.0,
        engineStatus: data['smi'] == 0 ? 'ON' : 'OFF',
        name: data['NAME']?.toString(),
        type: data['TYPENAME']?.toString(),
        navStatus: _getNavStatus(data['navstatus']),
        trueHeading: data['hdg']?.toDouble() ?? 0.0,
        cog: data['cog']?.toDouble() ?? 0.0,
        receivedOn: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing ship data: $e');
      rethrow;
    }
  }
  
  void updateFromJson(Map<String, dynamic> json) {
    try {
      final message = json['message'] as Map<String, dynamic>?;
      final data = message?['data'] as Map<String, dynamic>?;
      
      if (data == null || data['valid'] != true) return;

      latitude = data['lat']?.toDouble() ?? latitude;
      longitude = data['lon']?.toDouble() ?? longitude;
      speed = data['sog']?.toDouble() ?? speed;
      engineStatus = data['smi'] == 0 ? 'ON' : 'OFF';
      navStatus = _getNavStatus(data['navstatus']);
      trueHeading = data['hdg']?.toDouble() ?? trueHeading;
      cog = data['cog']?.toDouble() ?? cog;
    } catch (e) {
      print('Error updating ship data: $e');
    }
  }
  
  static String _getNavStatus(dynamic status) {
    switch(status) {
      case 0: return 'Under way using engine';
      case 1: return 'At anchor';
      case 2: return 'Not under command';
      case 3: return 'Restricted maneuverability';
      case 4: return 'Constrained by draught';
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