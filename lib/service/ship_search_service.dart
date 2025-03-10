import 'dart:convert';
import 'package:flutter/services.dart';

class ShipSearchService {
  Map<String, dynamic>? _searchIndex;

  Future<void> initializeIndex() async {
    if (_searchIndex != null) return;
    
    try {
      final jsonString = await rootBundle.loadString('assets/ship.json');
      final List<dynamic> ships = json.decode(jsonString);
      
      _searchIndex = {};
      for (var ship in ships) {
        if (ship['MMSI'] != null) {
          _searchIndex![ship['MMSI'].toString()] = {
            'name': ship['NAME'],
            'type': ship['TYPENAME'],
          };
        }
      }
    } catch (e) {
      print('Error initializing search index: $e');
    }
  }

  Map<String, String?>? findShipByMMSI(String mmsi) {
    if (_searchIndex == null || !_searchIndex!.containsKey(mmsi)) {
      return null;
    }
    
    final shipData = _searchIndex![mmsi];
    return {
      'name': shipData['name']?.toString(),
      'type': shipData['type']?.toString(),
    };
  }
}