import 'package:aisits_mobileapp/service/notification_service.dart';
import '../service/json_service_provider.dart';
import '../model/ship_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../service/ship_provider.dart';
import '../service/ship_service.dart';
import '../widget/polygon_widget.dart';
import '../widget/custom_drawer.dart';
import '../widget/ship_detail_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  late final ShipService _shipService;
  late final MapController _mapController;
  bool _keepAlive = true;
  bool _isInitialized = false;
  final Set<String> _markedShips = {};
  
  @override
  bool get wantKeepAlive => _keepAlive;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Hapus baris ini karena tidak ada Provider untuk ShipService
    // _shipService = Provider.of<ShipService>(context, listen: false);
    _initializeServices();
  }
  
  @override
  void dispose() {
    if (!_keepAlive) {
      _mapController.dispose();
    }
    super.dispose();
  }
  Future<void> _initializeServices() async {
    if (_isInitialized) return;
  
    final jsonProvider = Provider.of<JsonServiceProvider>(context, listen: false);
    if (!jsonProvider.isLoaded) {
      Navigator.pushReplacementNamed(context, '/splash');
      return;
    }
  
    final shipProvider = Provider.of<ShipProvider>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    shipProvider.onMarkerTap = _showShipDetails; 
    
    if (!shipProvider.isInitialized) {
      await shipProvider.initialize();
    }
  
    // Buat instance ShipService langsung di sini
    _shipService = ShipService(
      url: 'ws://146.190.89.97:6767',
      token: 'labramsjosgandoss',
      notificationService: notificationService, 
      onMarkerTap: _showShipDetails,
    );
  
    if (!_isInitialized) {
      await _shipService.loadShipData();
      _isInitialized = true;
    }
  
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shipService.listenToShipDataStream((ShipData data) {
          if (!mounted) return;
          Provider.of<ShipProvider>(context, listen: false).addShip(data);
        });
      });
    }
  }
  void _showShipDetails(ShipData shipData) {
    if (!mounted) return;
    
    print("Showing details for ship: ${shipData.name ?? 'Unknown'} (${shipData.id})");
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => ShipDetailDialog(shipData: shipData),
    ).then((_) => print("Dialog closed"));
  }
  // Remove _buildDetailRow method as it's now in ShipDetailDialog
  void _toggleMarkShip(ShipData shipData) {
    setState(() {
      if (_markedShips.contains(shipData.id)) {
        _markedShips.remove(shipData.id);
      } else {
        _markedShips.add(shipData.id);
      }
    });
    _showShipDetails(shipData);
  }
  Marker _createMarker(ShipData shipData) {
    final bool isMarked = _markedShips.contains(shipData.id);
    final double size = isMarked ? 60.0 : 40.0;
    
    return Marker(
      point: LatLng(shipData.latitude, shipData.longitude),
      width: size,
      height: size,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          _toggleMarkShip(shipData);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          color: Colors.transparent,
          child: Center(
            child: shipData.getIcon(),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marked Ships: ${_markedShips.length}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          Builder(
            builder: (BuildContext context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const CustomDrawer(),
      body: Consumer<ShipProvider>(
        builder: (context, shipProvider, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-7.257472, 112.752088),
                minZoom: 8.0,
                maxZoom: 14.0,
                onTap: (_, __) {
                  print("Map tapped");
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                // Removed HeatmapLayer and Consumer
                PolygonLayer(polygons: getPolygons()),
                MarkerLayer(
                  markers: shipProvider.ships.values.map((ship) => _createMarker(ship)).toList(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoomInButton",
            onPressed: () {
              _mapController.moveAndRotate(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
                0,
              );
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoomOutButton",
            onPressed: () {
              _mapController.moveAndRotate(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
                0,
              );
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
          
