import 'package:aisits_mobileapp/widget/polygon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../service/track_vessel_service.dart';

class TrackVesselScreen extends StatefulWidget {
  const TrackVesselScreen({super.key});

  @override
  _TrackVesselScreenState createState() => _TrackVesselScreenState();
}

class _TrackVesselScreenState extends State<TrackVesselScreen> {
  late final MapController _mapController;
  bool _isLoading = false;
  List<LatLng> _trackPoints = [];
  String? _selectedMmsi;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showTrackingModal() {
    final TextEditingController mmsiController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track Vessel'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: mmsiController,
                      decoration: const InputDecoration(
                        labelText: 'MMSI',
                        hintText: 'Enter vessel MMSI',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(startDate == null 
                          ? 'Select Start Date' 
                          : 'Start: ${DateFormat('yyyy-MM-dd').format(startDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(endDate == null 
                          ? 'Select End Date' 
                          : 'End: ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (mmsiController.text.isNotEmpty && startDate != null && endDate != null) {
                      Navigator.of(context).pop();
                      _fetchVesselTrack(
                        mmsiController.text,
                        startDate!,
                        endDate!,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _fetchVesselTrack(String mmsi, DateTime startDate, DateTime endDate) async {
    setState(() {
      _isLoading = true;
      _selectedMmsi = mmsi;
      _trackPoints = [];
    });

    try {
      final trackService = TrackVesselService();
      final trackPoints = await trackService.fetchVesselTrack(
        mmsi: mmsi,
        startDate: startDate,
        endDate: endDate,
        token: 'labramsjosgandoss',
      );
      
      setState(() {
        _trackPoints = trackPoints;
        _isLoading = false;
      });
      
      if (_trackPoints.isNotEmpty) {
        _mapController.move(_trackPoints.first, 12.0);
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching track data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/map'),
        ),
        title: _selectedMmsi != null 
            ? Text('Track Vessel: $_selectedMmsi') 
            : const Text('Track Vessel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showTrackingModal,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-7.257472, 112.752088),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolygonLayer(polygons: getPolygons()),
              if (_trackPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trackPoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              if (_trackPoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _trackPoints.first,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    Marker(
                      point: _trackPoints.last,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'trackVessel',
            onPressed: _showTrackingModal,
            child: const Icon(Icons.timeline),
          ),
          const SizedBox(height: 16),
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