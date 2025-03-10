import 'package:aisits_mobileapp/service/json_service.dart';
import 'package:aisits_mobileapp/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/ship_model.dart';
import '../utils/log_utils.dart';
import 'dart:collection';
import 'dart:async';

class ShipProvider with ChangeNotifier {
  static ShipProvider? _instance;
  final JsonService jsonService;
  final NotificationService notificationService;
  Function(ShipData)? onMarkerTap;
  bool _isInitialized = false;
  
  static const int maxCacheSize = 1000;
  static const Duration _batchDelay = Duration(milliseconds: 100);
  
  final Map<String, ShipData> _shipCache = {};
  final Map<String, Marker> _markers = {};
  final Queue<ShipData> _updateQueue = Queue<ShipData>();
  Timer? _batchTimer;
  
  Map<String, Marker> get markers => _markers;
  Map<String, ShipData> get ships => _shipCache;
  bool get isInitialized => _isInitialized;
  
  factory ShipProvider({
    required JsonService jsonService, 
    required NotificationService notificationService,
    Function(ShipData)? onMarkerTap,
  }) {
    return _instance ??= ShipProvider._internal(
      jsonService, 
      notificationService,
      onMarkerTap,
    );
  }
  
  ShipProvider._internal(
    this.jsonService, 
    this.notificationService,
    this.onMarkerTap,
  );
  
  Future<void> initialize() async {
    if (!_isInitialized) {
      await jsonService.loadShipData();
      _isInitialized = true;
      notifyListeners();
    }
  }

  void addShip(ShipData ship) {
    if (!_isInitialized) return;
    
    _updateQueue.add(ship);
    _scheduleBatchUpdate();
  }
  
  void _scheduleBatchUpdate() {
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDelay, _processBatchUpdates);
  }

  void _cleanCache() {
    if (_shipCache.length > maxCacheSize) {
      final keysToRemove = _shipCache.keys.take(_shipCache.length - maxCacheSize).toList();
      for (final key in keysToRemove) {
        _shipCache.remove(key);
        _markers.remove(key);
        LogUtils.info('Cleaned cache for ship: $key');
      }
      notifyListeners();
    }
  }
  
  void _processBatchUpdates() {
    if (_updateQueue.isEmpty) return;
  
    final batch = List<ShipData>.from(_updateQueue);
    _updateQueue.clear();
  
    for (final ship in batch) {
      final String mmsi = ship.id;
      jsonService.getShipData(mmsi).then((jsonShipData) {
        if (jsonShipData != null) {
          ship.name = jsonShipData['NAME']?.toString();
          ship.type = jsonShipData['TYPENAME']?.toString();
          LogUtils.info('Updated ship data - MMSI: $mmsi, Name: ${ship.name}, Type: ${ship.type}');
        }
  
        _shipCache[mmsi] = ship;
        _updateMarker(ship);
        
        if (_shipCache.length > maxCacheSize) {
          _cleanCache();
        }
        notifyListeners();
      }).catchError((error) {
        LogUtils.error('Error updating ship data', error);
      });
    }
  }
  
  void setOnMarkerTap(Function(ShipData) callback) {
    onMarkerTap = callback;
    notifyListeners();
  }
  
  void _updateMarker(ShipData shipData) {
    if (!_isValidCoordinates(shipData)) {
      LogUtils.error('Invalid coordinates', 'MMSI=${shipData.id}');
      return;
    }
    
    try {
      final String mmsi = shipData.id;
      _markers[mmsi] = Marker(
        point: LatLng(shipData.latitude, shipData.longitude),
        width: 40,
        height: 40,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              LogUtils.info("Marker tapped: ${shipData.name}");
              if (onMarkerTap != null) {
                onMarkerTap!(shipData);
              }
            },
            child: shipData.getIcon(),
          ),
        ),
      );
      notifyListeners();
    } catch (e) {
      LogUtils.error('Error updating marker: ${e.toString()}');
    }
  }

  bool _isValidCoordinates(ShipData shipData) {
    return shipData.latitude != 0.0 && 
           shipData.longitude != 0.0 && 
           shipData.latitude.abs() <= 90 && 
           shipData.longitude.abs() <= 180;
  }
  @override
  void dispose() {
    if (_instance == null) return;
    
    try {
      _batchTimer?.cancel();
      _shipCache.clear();
      _markers.clear();
      _updateQueue.clear();
      // Don't set _instance to null here
      notifyListeners();
    } catch (e) {
      LogUtils.error('Error disposing ShipProvider: ${e.toString()}');
    } finally {
      super.dispose();
    }
  }
  
  // Add cleanup method
  void cleanup() {
    _batchTimer?.cancel();
    _shipCache.clear();
    _markers.clear();
    _updateQueue.clear();
    _isInitialized = false;
  }
}