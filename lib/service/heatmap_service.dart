import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class HeatmapService extends ChangeNotifier {
  bool _showHeatmap = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<HeatPoint> _heatPoints = [];
  
  bool get showHeatmap => _showHeatmap;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<HeatPoint> get heatPoints => _heatPoints;
  
  void toggleHeatmap(bool value) {
    _showHeatmap = value;
    notifyListeners();
  }
  
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }
  
  Future<void> fetchHeatmapData() async {
    // In a real app, you would fetch data from an API
    // For now, we'll generate random data around the Madura Strait area
    
    // Clear existing points
    _heatPoints = [];
    
    // Generate random points around the Madura Strait
    final Random random = Random();
    
    // Base coordinates for Madura Strait
    const double baseLat = -7.2;
    const double baseLng = 112.7;
    
    // Generate clusters
    _generateCluster(baseLat, baseLng, 0.3, 50, random); // Main shipping lane
    _generateCluster(baseLat - 0.1, baseLng + 0.2, 0.1, 30, random); // Secondary cluster
    _generateCluster(baseLat + 0.2, baseLng - 0.1, 0.15, 20, random); // Tertiary cluster
    
    notifyListeners();
  }
  
  void _generateCluster(double centerLat, double centerLng, double radius, int count, Random random) {
    for (int i = 0; i < count; i++) {
      // Generate points within the radius of the center
      final double angle = random.nextDouble() * 2 * pi;
      final double distance = random.nextDouble() * radius;
      
      final double lat = centerLat + (distance * cos(angle));
      final double lng = centerLng + (distance * sin(angle));
      
      // Assign intensity based on proximity to center (higher near center)
      final double intensity = 1.0 - (distance / radius);
      
      _heatPoints.add(HeatPoint(
        point: LatLng(lat, lng),
        intensity: intensity,
      ));
    }
  }
}

class HeatPoint {
  final LatLng point;
  final double intensity; // 0.0 to 1.0
  
  HeatPoint({
    required this.point,
    required this.intensity,
  });
}