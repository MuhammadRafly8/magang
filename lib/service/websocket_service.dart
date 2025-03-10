import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/ship_model.dart';
import '../service/notification_service.dart';
import 'dart:convert';

// Debouncer class untuk menunda eksekusi fungsi
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer(this.delay);

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  
  factory WebSocketService(String url, String token, {Function(ShipData)? onMarkerTap}) {
    if (!_instance._isInitialized) {
      _instance._onMarkerTap = onMarkerTap;
      _instance._connect(url, token);
    }
    return _instance;
  }
  
  WebSocketService._internal();
  
  // Fungsi untuk mengonversi kode status navigasi ke string
  String _getNavStatus(dynamic status) {
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
  
  Function(ShipData)? _onMarkerTap;
  late final IO.Socket _socket;
  final StreamController<ShipData> _streamController = StreamController<ShipData>.broadcast();
  bool _isInitialized = false;
  int _reconnectAttempts = 0;
  final Debouncer _debouncer = Debouncer(const Duration(milliseconds: 50));
  bool _dataInitiallyLoaded = false;
  bool _isDisposed = false;
  
  void _connect(String url, String token) {
    _socket = IO.io(url, {
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });
  
    _socket.connect();
  
    _socket.onConnect((_) {
      print("WebSocket connected at ${DateTime.now()}");
      _reconnectAttempts = 0;
    });
    
    // Only set up the message handler if not already done
    if (!_dataInitiallyLoaded) {
      _socket.on('messageFromServer', (data) {
        try {
          // Handle both string and map data
          final Map<String, dynamic> jsonData = 
            data is String ? json.decode(data) : data as Map<String, dynamic>;
          
          // Extract ship data from the correct structure
          final message = jsonData['message'];
          final shipData = message?['data'];
          
          if (shipData != null) {
            // Pastikan tipe data sesuai dengan yang diharapkan
            final parsedShip = ShipData(
              id: shipData['mmsi']?.toString() ?? 'unknown',
              latitude: double.tryParse(shipData['lat']?.toString() ?? '0') ?? 0.0,
              longitude: double.tryParse(shipData['lon']?.toString() ?? '0') ?? 0.0,
              speed: double.tryParse(shipData['sog']?.toString() ?? '0') ?? 0.0,
              trueHeading: double.tryParse(shipData['hdg']?.toString() ?? '0') ?? 0.0,
              cog: double.tryParse(shipData['cog']?.toString() ?? '0') ?? 0.0,
              navStatus: _getNavStatus(shipData['navstatus']),
              name: shipData['NAME']?.toString() ?? 'Unknown',
              type: shipData['TYPENAME']?.toString() ?? 'Unknown',
              engineStatus: shipData['smi'] == 0 ? 'ON' : 'OFF',
              receivedOn: DateTime.tryParse(jsonData['timestamp']?.toString() ?? '') ?? DateTime.now(),
            );
            
            // Less restrictive validation
            if (_isValidShipData(parsedShip)) {
              _streamController.add(parsedShip);
            }
          }
        } catch (e) {
          print('WebSocket data processing error: $e');
        }
      });
    }
    
    _dataInitiallyLoaded = true;

    _socket.onDisconnect((_) {
      print("WebSocket disconnected");
      _reconnect();
    });

    _socket.onConnectError((error) {
      print("WebSocket connection error: $error");
      _reconnect();
    });
  
    _socket.onError((error) {
      print("WebSocket error: $error");
      _reconnect();
    });
  
    _isInitialized = true;
  }
  
  void _reconnect() {
    if (_reconnectAttempts < 5) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      print("Reconnecting in ${delay.inSeconds} seconds...");
      if (!_isDisposed) {
        Future.delayed(delay, () {
          if (!_isDisposed) {
            _socket.connect();
          }
        });
      }
    } else {
      print("Max reconnection attempts reached.");
      NotificationService().addDangerMessage("Gagal terhubung ke server. Silakan coba lagi nanti.");
    }
  }
  
  // Method to maintain connection when navigating
  void preserveConnection() {
    _dataInitiallyLoaded = true;
    // Don't disconnect or reconnect, just maintain the current state
  }
  
  // Modified dispose method to be more selective
  void dispose() {
    if (!_dataInitiallyLoaded) {
      _isDisposed = true;
      _socket.disconnect();
      _streamController.close();
      _debouncer.dispose();
    }
  }
  
  bool _isValidShipData(ShipData ship) {
    // More permissive validation to allow more data through
    return ship.id.isNotEmpty && 
           ship.id != 'unknown' &&
           (ship.latitude != 0.0 || ship.longitude != 0.0) && 
           ship.latitude.abs() <= 90.1 && // Slightly expanded range
           ship.longitude.abs() <= 180.1; // Slightly expanded range
  }
  
  Stream<ShipData> get shipDataStream => _streamController.stream;
  
  void updateToken(String newToken) {
    _socket.disconnect();
    _socket.io.options?['auth'] = {'token': newToken};
    _socket.connect();
    print("Updated WebSocket token to: $newToken");
  }
  
  void close() {
    _socket.disconnect();
    _streamController.close();
    _debouncer.dispose();
    print("WebSocket and StreamController closed.");
  }
  
  void handleMarkerTap(ShipData shipData) {
    if (_onMarkerTap != null) {
      _onMarkerTap!(shipData);
    }
  }
}