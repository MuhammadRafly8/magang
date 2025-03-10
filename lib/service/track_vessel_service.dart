import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:aisits_mobileapp/utils/log_utils.dart';

class TrackVesselService {
  static const String baseUrl = 'http://146.190.89.97:6767'; // Replace with your actual API base URL
  
  Future<List<LatLng>> fetchVesselTrack({
    required String mmsi,
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/api/track');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'mmsi': mmsi,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseTrackPoints(data);
      } else {
        LogUtils.error('Failed to fetch vessel track', 
          'Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch vessel track: ${response.statusCode}');
      }
    } catch (e) {
      LogUtils.error('Error fetching vessel track', e);
      throw Exception('Error fetching vessel track: $e');
    }
  }
  
  List<LatLng> _parseTrackPoints(List<dynamic> data) {
    try {
      return data.map((point) {
        return LatLng(
          double.parse(point['latitude'].toString()),
          double.parse(point['longitude'].toString()),
        );
      }).toList();
    } catch (e) {
      LogUtils.error('Error parsing track points', e);
      throw Exception('Error parsing track points: $e');
    }
  }
}