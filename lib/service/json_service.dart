import 'dart:convert';
import 'package:flutter/services.dart';

class JsonService {
  Map<String, dynamic> _shipDataMap = {};

  Future<List<dynamic>> loadShipData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/ship.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Update the ship data map
      for (var ship in jsonData) {
        if (ship['MMSI'] != null) {
          _shipDataMap[ship['MMSI'].toString()] = ship;
        }
      }
      
      print('Successfully loaded ${jsonData.length} ships from JSON');
      return jsonData;
    } catch (e) {
      print('Error loading ship data: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getShipData(String mmsi) async {
    // Use cached data if available
    if (_shipDataMap.containsKey(mmsi)) {
      final ship = _shipDataMap[mmsi];
      print('Found cached ship data for MMSI $mmsi: $ship');
      return ship;
    }

    try {
      // If not in cache, load from JSON
      if (_shipDataMap.isEmpty) {
        await loadShipData();
      }

      if (_shipDataMap.containsKey(mmsi)) {
        final ship = _shipDataMap[mmsi];
        print('Ship type for MMSI $mmsi: ${ship['TYPENAME']}'); // Debug log for ship type
        return ship;
      }

      print('No ship data found for MMSI: $mmsi');
      return null;
    } catch (e) {
      print('Error getting ship data: $e');
      return null;
    }
  }
}