
import 'package:flutter/foundation.dart';
import '../model/ship_model.dart';

Future<ShipData> parseShipData(Map json) async {
  return compute(_parseShipData, json);
}

ShipData _parseShipData(Map json) {
  try {
    final message = json['message'] as Map<String, dynamic>?;
    final data = message?['data'] as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('Invalid JSON structure: Missing data');
    }
    
    if (data['valid'] == false) {
      throw Exception('Invalid ship data: ${data['error']}');
    }

    return ShipData.fromJson(data);
  } catch (e) {
    print('Error parsing ship data: $e');
    rethrow;
  }
}