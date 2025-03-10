import 'package:flutter/material.dart';
import 'json_service.dart';
import 'ship_search_service.dart';

class JsonServiceProvider with ChangeNotifier {
  final JsonService _jsonService = JsonService();
  final ShipSearchService _searchService = ShipSearchService();
  bool _isLoaded = false;
  bool _isInitializing = false;

  bool get isLoaded => _isLoaded;
  JsonService get jsonService => _jsonService;

  Future<void> initializeData() async {
    if (!_isLoaded && !_isInitializing) {
      _isInitializing = true;
      try {
        await _jsonService.loadShipData();
        await _searchService.initializeIndex();
        _isLoaded = true;
        notifyListeners();
      } finally {
        _isInitializing = false;
      }
    }
  }

  Map<String, String?>? getShipData(String mmsi) {
    return _searchService.findShipByMMSI(mmsi);
  }
}