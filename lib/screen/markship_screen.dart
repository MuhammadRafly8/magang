import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../service/ship_provider.dart';
import '../model/ship_model.dart';
import '../widget/polygon_widget.dart';

class MarkShipScreen extends StatefulWidget {
  const MarkShipScreen({super.key});

  @override
  State<MarkShipScreen> createState() => _MarkShipScreenState();
}

class _MarkShipScreenState extends State<MarkShipScreen> {
  final MapController _mapController = MapController();
  final Set<String> _markedShips = {};
  
  void _toggleMarkShip(String shipId) {
    setState(() {
      if (_markedShips.contains(shipId)) {
        _markedShips.remove(shipId);
      } else {
        _markedShips.add(shipId);
      }
    });
  }

  Marker _createMarker(ShipData shipData, bool isMarked) {
    final double size = isMarked ? 60.0 : 40.0;
    
    return Marker(
      point: LatLng(shipData.latitude, shipData.longitude),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _toggleMarkShip(shipData.id),
        child: Stack(
          children: [
            Transform.rotate(
              angle: (shipData.trueHeading > 0 ? shipData.trueHeading : shipData.cog) * (3.14159265359 / 180.0),
              child: shipData.getIcon(),
            ),
            if (isMarked)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/map'),
        ),
        title: const Text('Mark Ships'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _markedShips.clear();
              });
            },
          ),
        ],
      ),
      body: Consumer<ShipProvider>(
        builder: (context, shipProvider, _) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-7.257472, 112.752088),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PolygonLayer(polygons: getPolygons()),
              MarkerLayer(
                markers: shipProvider.ships.values.map((ship) {
                  return _createMarker(ship, _markedShips.contains(ship.id));
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: () {
              _mapController.moveAndRotate(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
                0,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: () {
              _mapController.moveAndRotate(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
                0,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}