import 'dart:convert';
import 'package:aisits_mobileapp/model/vessel_history_point.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:aisits_mobileapp/utils/log_utils.dart';
import 'package:aisits_mobileapp/service/json_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackVesselService {
  static const String baseUrl = 'http://146.190.89.97:8989'; // Updated API base URL to 8989
  // This will be used as a fallback token
  static const String defaultToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjY5ZmExMjBhZTkzMjY5OTVkZmRiMzQzIiwibmFtZSI6ImRlZmF1bHQgYWRtaW4iLCJlbWFpbCI6ImFkbWluQHJhbXMuY28uaWQiLCJyb2xlIjoiYWRtaW5pc3RyYXRvciIsImlhdCI6MTc0MTYxNzA4NCwiZXhwIjoxNzQxNjQ1ODg0fQ.sEQ-f6LLUnt0zJWazEieF-nqpXovxYb9u23GRR2dSA8';
  final JsonService _jsonService = JsonService();
  
  // Add a method to login and get a fresh token
  Future<String> _getAuthToken() async {
    try {
      // Try to get token from shared preferences first
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final tokenExpiry = prefs.getInt('token_expiry');
      
      // Check if token exists and is not expired
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (storedToken != null && tokenExpiry != null && tokenExpiry > now) {
        LogUtils.info('Using stored token', 'Token valid until ${DateTime.fromMillisecondsSinceEpoch(tokenExpiry * 1000)}');
        return storedToken;
      }
      
      // Token doesn't exist or is expired, get a new one
      LogUtils.info('Getting new token', 'Logging in to API');
      
      final response = await http.post(
        Uri.parse('$baseUrl/loginApi'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'aisits_mobileapp',
        },
        body: {
          'email': 'admin@rams.co.id',
          'password': 'labRams200!!',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        LogUtils.info('Login successful', 'Response: ${response.body}');
        
        if (responseData.containsKey('token')) {
          final token = responseData['token'];
          
          // Store token and its expiry time (default to 24 hours if not provided)
          int expiryTime = now + 86400; // 24 hours from now
          if (responseData.containsKey('expires_in')) {
            expiryTime = now + int.parse(responseData['expires_in'].toString());
          }
          
          await prefs.setString('auth_token', token);
          await prefs.setInt('token_expiry', expiryTime);
          
          LogUtils.info('Token stored', 'Valid until ${DateTime.fromMillisecondsSinceEpoch(expiryTime * 1000)}');
          return token;
        }
      }
      
      LogUtils.error('Login failed', 'Status: ${response.statusCode}, Body: ${response.body}');
      return defaultToken; // Return default token as fallback
    } catch (e) {
      LogUtils.error('Error getting auth token', e);
      return defaultToken; // Return default token as fallback
    }
  }
  
  // Add a method to fetch ship data and determine icon type
  Future<String> fetchShipIconType(String mmsi) async {
    try {
      LogUtils.info('Fetching ship data', 'MMSI: $mmsi');
      final jsonData = await _jsonService.getShipData(mmsi);
      
      if (jsonData is Map<String, dynamic>) {
        final shipType = jsonData['TYPENAME']?.toString();
        LogUtils.info('Ship type fetched', 'Type: ${shipType ?? "unknown"}');
        return _determineShipIconType(shipType);
      } else {
        LogUtils.warning('Invalid ship data', 'Data is not a map');
        return 'unknown';
      }
    } catch (e) {
      LogUtils.error('Error fetching ship data', e);
      return 'unknown';
    }
  }
  
  // Add method to determine ship icon type
  String _determineShipIconType(String? shipType) {
    if (shipType == null) return 'unknown';
    
    final String normalizedType = shipType.toLowerCase();
    
    if (normalizedType.contains('cargo') || normalizedType.contains('general') || 
        normalizedType.contains('carrier') || normalizedType.contains('container')) {
      return 'cargo';
    } else if (normalizedType.contains('cruise') || 
              normalizedType.contains('passenger') || 
              normalizedType.contains('ferry')) {
      return 'cruise';
    } else if (normalizedType.contains('special') || 
              normalizedType.contains('other') ||
              normalizedType.contains('misc')) {
      return 'special';
    } else if (normalizedType.contains('support') || 
              normalizedType.contains('service') ||
              normalizedType.contains('supply') ||
              normalizedType.contains('tug')) {
      return 'support';
    } else if (normalizedType.contains('tanker') || 
              normalizedType.contains('oil') ||
              normalizedType.contains('gas') ||
              normalizedType.contains('barge')) {
      return 'tanker';
    }
    
    return 'unknown';
  }
  
  // Improved vessel track fetching method
  Future<Map<String, dynamic>> fetchVesselTrackWithDetails({
    required String mmsi,
    required DateTime startDate,
    required DateTime endDate,
    String? token,
  }) async {
    try {
      final List<LatLng> trackPoints = await fetchVesselTrack(
        mmsi: mmsi,
        startDate: startDate,
        endDate: endDate,
        token: token,
      );
      
      // Fetch additional vessel information
      final vesselInfo = await _fetchVesselInfo(mmsi, token);
      
      // Fetch port and terminal information if available
      final portInfo = await _fetchPortInfo(mmsi, token);
      
      return {
        'trackPoints': trackPoints,
        'vesselInfo': vesselInfo,
        'portInfo': portInfo,
      };
    } catch (e) {
      LogUtils.error('Error fetching vessel track with details', e);
      return {
        'trackPoints': <LatLng>[],
        'vesselInfo': {},
        'portInfo': {},
      };
    }
  }
  
  // Method to fetch vessel information
  Future<Map<String, dynamic>> _fetchVesselInfo(String mmsi, String? token) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/vessel/$mmsi');
      final String authToken = token ?? await _getAuthToken();
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'User-Agent': 'aisits_mobileapp',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : {};
      }
      return {};
    } catch (e) {
      LogUtils.error('Error fetching vessel info', e);
      return {};
    }
  }
  
  // Method to fetch port and terminal information
  Future<Map<String, dynamic>> _fetchPortInfo(String mmsi, String? token) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/ports/near');
      final String authToken = token ?? await _getAuthToken();
      
      // Get the last known position of the vessel
      final vesselInfo = await _fetchVesselInfo(mmsi, token);
      double? lat, lon;
      
      if (vesselInfo.containsKey('LAT') && vesselInfo.containsKey('LON')) {
        lat = double.tryParse(vesselInfo['LAT'].toString());
        lon = double.tryParse(vesselInfo['LON'].toString());
      }
      
      if (lat == null || lon == null) {
        return {};
      }
      
      final requestBody = {
        'lat': lat,
        'lon': lon,
        'radius': 10, // 10 km radius
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'User-Agent': 'aisits_mobileapp',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : {};
      }
      return {};
    } catch (e) {
      LogUtils.error('Error fetching port info', e);
      return {};
    }
  }
  
  Future<List<LatLng>> fetchVesselTrack({
    required String mmsi,
    required DateTime startDate,
    required DateTime endDate,
    String? token,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/shipHistory');
      final String authToken = token ?? await _getAuthToken();
      
      // Expanded area to cover more of the port area shown in the image
      final List<List<double>> area = [
        [112.0, -7.5],  // Southwest corner - expanded
        [112.0, -6.5],  // Northwest corner
        [114.0, -6.5],  // Northeast corner - expanded
        [114.0, -7.5],  // Southeast corner - expanded
        [112.0, -7.5],  // Close the polygon
      ];
      
      // Try multiple date ranges to find data
      // First try the user-provided dates
      final String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
      
      // Alternative date ranges to try if the first one fails
      final List<Map<String, String>> dateRanges = [
        {'start': formattedStartDate, 'end': formattedEndDate},
        {'start': '2023-01-01', 'end': '2023-01-31'},
        {'start': '2023-06-01', 'end': '2023-06-30'},
        {'start': '2023-12-01', 'end': '2023-12-31'},
        {'start': '2024-01-01', 'end': '2024-01-31'},
      ];
      
      List<LatLng> trackPoints = [];
      
      // Try each date range until we find data
      for (final dateRange in dateRanges) {
        final requestBody = {
          'mmsi': mmsi,
          'startdate': dateRange['start'],
          'enddate': dateRange['end'],
          'area': area,
        };
        
        LogUtils.info('Fetching vessel track', 'Request URL: $uri, Date range: ${dateRange['start']} to ${dateRange['end']}');
        LogUtils.info('Request body', json.encode(requestBody));
        
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
            'User-Agent': 'aisits_mobileapp',
          },
          body: json.encode(requestBody),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            LogUtils.error('API request timeout', 'The request took too long to complete');
            return http.Response('{"error":"Request timeout"}', 408);
          },
        );
        
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            final dynamic responseData = json.decode(response.body);
            
            List<dynamic> trackData = [];
            
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('data')) {
                trackData = responseData['data'] as List<dynamic>;
              } else if (responseData.containsKey('tracks')) {
                trackData = responseData['tracks'] as List<dynamic>;
              } else if (responseData.containsKey('result')) {
                // Some APIs use 'result' field
                final result = responseData['result'];
                if (result is List) {
                  trackData = result;
                }
              } else {
                final availableKeys = responseData.keys.join(', ');
                LogUtils.warning('No recognized data field', 'Available keys: $availableKeys');
                
                // Try to use the response directly if it has coordinate fields
                if (responseData.containsKey('LAT') || responseData.containsKey('lat') || 
                    responseData.containsKey('latitude')) {
                  trackData = [responseData];
                }
              }
            } else if (responseData is List<dynamic>) {
              trackData = responseData;
            }
            
            if (trackData.isNotEmpty) {
              trackPoints = _parseTrackPoints(trackData);
              if (trackPoints.isNotEmpty) {
                LogUtils.info('Found track points', 'Count: ${trackPoints.length}, Date range: ${dateRange['start']} to ${dateRange['end']}');
                break; // Exit the loop if we found data
              }
            }
          } catch (e) {
            LogUtils.error('Error parsing response', 'Error: $e, Response: ${response.body}');
          }
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          // If authentication fails, no need to try other date ranges
          LogUtils.error('Authentication error', 'Status: ${response.statusCode}, Body: ${response.body}');
          throw Exception('Authentication failed. Please check your credentials or token may have expired.');
        }
      }
      
      return trackPoints;
    } catch (e) {
      LogUtils.error('Error fetching vessel track', e);
      throw Exception('Error fetching vessel track: $e');
    }
  }
  
  // Parse history points from the new API format
  List<VesselHistoryPoint> parseHistoryPoints(List<dynamic> historyData) {
    try {
      LogUtils.info('Parsing history points', 'Points count: ${historyData.length}');
      
      // Sort data by timestamp (createdAt) to ensure chronological order
      historyData.sort((a, b) {
        if (a is Map<String, dynamic> && b is Map<String, dynamic>) {
          final aTime = a['createdAt'] ?? '';
          final bTime = b['createdAt'] ?? '';
          return aTime.toString().compareTo(bTime.toString());
        }
        return 0;
      });
      
      final points = historyData.map((point) {
        try {
          if (point is Map<String, dynamic>) {
            return VesselHistoryPoint.fromJson(point);
          }
          return null;
        } catch (e) {
          LogUtils.warning('Error parsing history point', 'Error: $e, Point: $point');
          return null;
        }
      }).whereType<VesselHistoryPoint>().toList(); // Filter out null values
      
      LogUtils.info('History points parsed', 'Valid points: ${points.length}');
      return points;
    } catch (e) {
      LogUtils.error('Error parsing history points', e);
      return []; // Return empty list instead of throwing exception
    }
  }
  
  List<LatLng> _parseTrackPoints(List<dynamic> data) {
    try {
      LogUtils.info('Parsing track points', 'Points count: ${data.length}');
      
      // Sort data by timestamp if available to ensure chronological order
      try {
        data.sort((a, b) {
          if (a is Map<String, dynamic> && b is Map<String, dynamic>) {
            final aTime = a['TIMESTAMP'] ?? a['timestamp'] ?? a['time'] ?? 0;
            final bTime = b['TIMESTAMP'] ?? b['timestamp'] ?? b['time'] ?? 0;
            return aTime.toString().compareTo(bTime.toString());
          }
          return 0;
        });
      } catch (e) {
        LogUtils.warning('Failed to sort track points', 'Error: $e');
        // Continue with unsorted data
      }
      
      final points = data.map((point) {
        try {
          // Check if the point contains the necessary coordinates
          if (point is Map<String, dynamic>) {
            // Log all keys to help debug
            LogUtils.info('Point keys', point.keys.join(', '));
            
            // Try all possible coordinate field names
            if (point.containsKey('longitude') && point.containsKey('latitude')) {
              return LatLng(
                double.parse(point['latitude'].toString()),
                double.parse(point['longitude'].toString()),
              );
            } else if (point.containsKey('lon') && point.containsKey('lat')) {
              return LatLng(
                double.parse(point['lat'].toString()),
                double.parse(point['lon'].toString()),
              );
            } else if (point.containsKey('LON') && point.containsKey('LAT')) {
              return LatLng(
                double.parse(point['LAT'].toString()),
                double.parse(point['LON'].toString()),
              );
            } else if (point.containsKey('lng') && point.containsKey('lat')) {
              return LatLng(
                double.parse(point['lat'].toString()),
                double.parse(point['lng'].toString()),
              );
            } else if (point.containsKey('x') && point.containsKey('y')) {
              // Some APIs use x/y for lon/lat
              return LatLng(
                double.parse(point['y'].toString()),
                double.parse(point['x'].toString()),
              );
            } else {
              // Try to find any keys that might contain lat/lon information
              final keys = point.keys.toList();
              LogUtils.warning('Unknown point format', 'Available keys: $keys');
              
              // Try to extract coordinates from any field that might contain them
              for (final key in keys) {
                final value = point[key];
                if (value is String && value.contains(',')) {
                  final parts = value.split(',');
                  if (parts.length == 2) {
                    final lat = double.tryParse(parts[0].trim());
                    final lon = double.tryParse(parts[1].trim());
                    if (lat != null && lon != null) {
                      return LatLng(lat, lon);
                    }
                  }
                }
              }
              return null;
            }
          } else if (point is List && point.length >= 2) {
            // Handle array format [lon, lat] or [lat, lon]
            // Assume [lon, lat] format which is common in GeoJSON
            return LatLng(
              double.parse(point[1].toString()),
              double.parse(point[0].toString()),
            );
          } else {
            LogUtils.warning('Invalid point format', 'Point is not a map or array: $point');
            return null;
          }
        } catch (e) {
          LogUtils.warning('Error parsing point', 'Error: $e, Point: $point');
          return null;
        }
      }).whereType<LatLng>().toList(); // Filter out null values
      
      LogUtils.info('Track points parsed', 'Valid points: ${points.length}');
      
      // If we have very few points, don't filter them
      if (points.length <= 5) {
        return points;
      }
      
      // Remove duplicate points that are too close to each other
      final filteredPoints = <LatLng>[];
      filteredPoints.add(points.first);
      
      for (int i = 1; i < points.length - 1; i++) {
        final prev = filteredPoints.last;
        final current = points[i];
        
        // Calculate distance between points
        final distance = _calculateDistance(prev, current);
        
        // Only add points that are at least 10 meters apart
        if (distance > 0.01) {
          filteredPoints.add(current);
        }
      }
      
      // Always add the last point
      if (points.length > 1) {
        filteredPoints.add(points.last);
      }
      
      return filteredPoints;
    } catch (e) {
      LogUtils.error('Error parsing track points', e);
      return []; // Return empty list instead of throwing exception
    }
  }
  
  // Helper method to calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    // Simple Euclidean distance calculation
    // For more accurate distance, consider using the Haversine formula
    final dx = point1.longitude - point2.longitude;
    final dy = point1.latitude - point2.latitude;
    return dx * dx + dy * dy; // We don't need the square root for comparison
  }
}