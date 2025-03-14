import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../model/vessel_history_point.dart';
import '../service/json_service.dart';

class TrackVesselService {
  final String baseUrl = 'http://146.190.89.97:8989';
  String? _authToken;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final JsonService _jsonService = JsonService();

  // Method to authenticate and get token
  Future<String> _authenticate() async {
    // If we already have a token, return it
    if (_authToken != null) {
      return _authToken!;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/loginApi'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'AISS-Mobile-App',
      },
      body: {
        'email': 'admin@rams.co.id',
        'password': 'labRams200!!',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _authToken = data['token'];
      return _authToken!;
    } else {
      throw Exception('Failed to authenticate: ${response.statusCode} - ${response.body}');
    }
  }

  // Method to fetch ship icon type based on MMSI
  Future<String> fetchShipIconType(String mmsi) async {
    try {
      // First try to get ship type from local JSON data
      final shipData = await _jsonService.getShipData(mmsi);
      
      if (shipData != null && shipData.containsKey('TYPENAME')) {
        final shipType = shipData['TYPENAME'] as String? ?? 'unknown';
        return _mapShipTypeToIcon(shipType);
      }
      
      // If not found in local data, try to get from API
      final trackData = await fetchVesselTrackWithDetails(
        mmsi: mmsi,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now(),
      );
      
      final shipType = trackData['shipType'] as String? ?? 'unknown';
      return _mapShipTypeToIcon(shipType);
    } catch (e) {
      print('Error fetching ship icon type: $e');
      return 'unknown'; // Default icon on error
    }
  }
  
  // Helper method to map ship type to icon file name
  String _mapShipTypeToIcon(String shipType) {
    final type = shipType.toLowerCase();
    
    if (type.contains('cargo') || type.contains('bulk')) {
      return 'cargo';
    } else if (type.contains('tanker') || type.contains('oil')) {
      return 'tanker';
    } else if (type.contains('passenger') || type.contains('cruise') || type.contains('ferry')) {
      return 'cruise';
    } else if (type.contains('fishing')) {
      return 'fishing';
    } else if (type.contains('tug') || type.contains('supply') || type.contains('service')) {
      return 'support';
    } else if (type.contains('special')) {
      return 'special';
    } else {
      return 'unknown';
    }
  }

  // Main method to fetch vessel track data with details
  Future<Map<String, dynamic>> fetchVesselTrackWithDetails({
    required String mmsi,
    required DateTime startDate,
    required DateTime endDate,
    List<List<double>>? area,
  }) async {
    try {
      final token = await _authenticate();
      
      // Default area if none provided (Surabaya port area)
      final requestArea = area ?? [
        [112.34059899836319, -7.274263912082582],
        [112.34059899836319, -6.623683386106124],
        [113.14714605172394, -6.623683386106124],
        [113.14714605172394, -7.274263912082582],
        [112.34059899836319, -7.274263912082582]
      ];
      
      final response = await http.post(
        Uri.parse('$baseUrl/shipHistory'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'User-Agent': 'AISS-Mobile-App',
        },
        body: json.encode({
          'mmsi': mmsi,
          'startdate': _dateFormat.format(startDate),
          'enddate': _dateFormat.format(endDate),
          'area': requestArea,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Extract ship data
        final shipData = data['shipData'] ?? {};
        final shipName = shipData['shipName'] as String? ?? 'Unknown Vessel';
        final shipType = shipData['shipType'] as String? ?? 'unknown';
        
        // Try to get additional ship info from local JSON
        String enhancedShipType = shipType;
        String shipFlag = '';
        
        final localShipData = await _jsonService.getShipData(mmsi);
        if (localShipData != null) {
          enhancedShipType = localShipData['TYPENAME'] ?? shipType;
          shipFlag = localShipData['FLAG'] ?? '';
        }
        
        // Extract history points and convert to model objects
        final historyList = data['history'] as List<dynamic>? ?? [];
        final List<VesselHistoryPoint> historyPoints = [];
        
        for (var point in historyList) {
          if (point is Map<String, dynamic> && 
              point.containsKey('lat') && 
              point.containsKey('lon')) {
            try {
              final historyPoint = VesselHistoryPoint.fromJson(point);
              historyPoints.add(historyPoint);
            } catch (e) {
              print('Error parsing history point: $e');
              // Continue with next point if there's an error
            }
          }
        }
        
        // Convert history points to track points for map display
        final List<LatLng> trackPoints = historyPoints.map((point) => point.toLatLng()).toList();
        
        // Get the icon type based on ship type
        final iconType = _mapShipTypeToIcon(enhancedShipType);
        
        return {
          'mmsi': mmsi,
          'shipName': shipName,
          'shipType': enhancedShipType,
          'shipFlag': shipFlag,
          'iconType': iconType,
          'trackPoints': trackPoints,
          'historyPoints': historyPoints,
        };
      } else {
        throw Exception('Failed to fetch vessel track: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching vessel track: $e');
    }
  }
  
  // Helper method to get navigation status description
  String getNavStatusDescription(int navStatus) {
    switch (navStatus) {
      case 0:
        return 'Under way using engine';
      case 1:
        return 'At anchor';
      case 2:
        return 'Not under command';
      case 3:
        return 'Restricted maneuverability';
      case 4:
        return 'Constrained by her draught';
      case 5:
        return 'Moored';
      case 6:
        return 'Aground';
      case 7:
        return 'Engaged in fishing';
      case 8:
        return 'Under way sailing';
      case 9:
        return 'Reserved for future amendment';
      case 10:
        return 'Reserved for future amendment';
      case 11:
        return 'Power-driven vessel towing astern';
      case 12:
        return 'Power-driven vessel pushing ahead/towing alongside';
      case 13:
        return 'Reserved for future amendment';
      case 14:
        return 'AIS-SART (active), MOB-AIS, EPIRB-AIS';
      case 15:
        return 'Undefined';
      default:
        return 'Unknown';
    }
  }
}