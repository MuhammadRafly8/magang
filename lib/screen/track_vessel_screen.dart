import 'package:aisits_mobileapp/widget/polygon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../service/track_vessel_service.dart';
import 'dart:math' show atan2;

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
  String _shipType = 'unknown'; // Add this property to fix the undefined variable
  
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
  
  // Modify the _fetchVesselTrack method to better handle the response
  Future<void> _fetchVesselTrack(String mmsi, DateTime startDate, DateTime endDate) async {
    setState(() {
      _isLoading = true;
      _selectedMmsi = mmsi;
      _trackPoints = [];
      _shipType = 'unknown'; // Reset ship type
    });
  
    try {
      final trackService = TrackVesselService();
      
      // First fetch ship type
      final shipIconType = await trackService.fetchShipIconType(mmsi);
      
      // Then fetch track points with details
      final trackData = await trackService.fetchVesselTrackWithDetails(
        mmsi: mmsi,
        startDate: startDate,
        endDate: endDate,
      );
      
      final trackPoints = trackData['trackPoints'] as List<LatLng>;
      
      setState(() {
        _shipType = shipIconType;
        _trackPoints = trackPoints;
        _isLoading = false;
      });
      
      if (_trackPoints.isNotEmpty) {
        // Center the map on the first point with appropriate zoom
        _mapController.move(_trackPoints.first, 10.0);
        
        // Show success message if we have track points
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${_trackPoints.length} track points for vessel $mmsi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Show warning if no track points found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No track points found for vessel $mmsi in the selected date range'),
            backgroundColor: Colors.orange,
          ),
        );
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

  // Improved build method with better visualization
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/map'),
        ),
        title: _selectedMmsi != null 
            ? Row(
                children: [
                  Text('Track: $_selectedMmsi'),
                  const SizedBox(width: 8),
                  _getShipIcon(_shipType),
                ],
              )
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
              initialCenter: const LatLng(-7.257472, 112.752088), // Surabaya port area
              initialZoom: 10,
              onTap: (_, point) {
                // Hide any info windows when tapping elsewhere on the map
                setState(() {
                  // Add code here if you want to handle map taps
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.aisits.mobileapp',
              ),
              // Add polygon layer for area visualization
              PolygonLayer(polygons: getPolygons()),
              
              // Add vessel track polyline with improved styling
              if (_trackPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trackPoints,
                      // Change color to gray to match the example image
                      color: Colors.grey.withOpacity(0.8),
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
                
              // Add direction arrows along the track
              if (_trackPoints.length > 5)
                MarkerLayer(
                  markers: _createDirectionArrows(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _getArrowPoints(),
                      color: Colors.transparent, // Transparent line
                      strokeWidth: 1.0,
                      // Remove the isDotted parameter completely
                      borderColor: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
                  ],
                ),
                
              // Add markers for start, end, and intermediate points
              if (_trackPoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    // Start marker (anchor icon)
                    Marker(
                      point: _trackPoints.first,
                      width: 40,
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.anchor,
                            color: Colors.purple,
                            size: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.white70,
                            child: const Text(
                              'START',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add intermediate ship markers
                    ..._createShipTrackMarkers(),
                    
                    // End marker (current position)
                    if (_trackPoints.length > 1)
                      Marker(
                        point: _trackPoints.last,
                        width: 40,
                        height: 40,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: _getShipIcon(_shipType, size: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.white70,
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Add port marker (similar to Terminal Nilam in the example)
                    Marker(
                      point: const LatLng(-7.257472, 112.752088), // Surabaya port
                      width: 80,
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            color: Colors.black,
                            size: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            color: Colors.white70,
                            child: const Text(
                              'Terminal Nilam',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
              // Add direction arrows as separate markers
              if (_trackPoints.length > 5)
                MarkerLayer(
                  markers: _createDirectionArrows(),
                ),
            ],
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          // Legend box
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Legend:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.anchor, color: Colors.purple, size: 16),
                      const SizedBox(width: 4),
                      const Text('Start Position'),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 3,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      const Text('Vessel Track'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      const Text('Direction'),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: _getShipIcon(_shipType, size: 12),
                      ),
                      const SizedBox(width: 4),
                      const Text('Current Position'),
                    ],
                  ),
                ],
              ),
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
  
  // New method to create direction arrow points
  List<LatLng> _getArrowPoints() {
    if (_trackPoints.length < 5) return [];
    return _trackPoints;
  }
  
  // New method to create direction arrow markers
  List<Marker> _createDirectionArrows() {
    if (_trackPoints.length < 5) return [];
    
    final List<Marker> arrows = [];
    final int totalPoints = _trackPoints.length;
    
    // Add arrows at regular intervals
    int step = (totalPoints / 8).ceil().clamp(3, 20);
    
    for (int i = step; i < totalPoints - step; i += step) {
      // Calculate direction angle
      final angle = _calculateRotationAngle(i);
      
      arrows.add(
        Marker(
          point: _trackPoints[i],
          width: 20,
          height: 20,
          child: Transform.rotate(
            angle: angle,
            child: Icon(
              // Change to arrow_forward and red color to match the example
              Icons.arrow_forward,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      );
    }
    
    return arrows;
  }
  
  // Improved method to create ship track markers
  List<Marker> _createShipTrackMarkers() {
    if (_trackPoints.length < 2) {
      if (_trackPoints.length == 1) {
        return [
          Marker(
            point: _trackPoints.first,
            width: 30,
            height: 30,
            child: _getShipIcon(_shipType),
          )
        ];
      }
      return [];
    }
    
    final List<Marker> markers = [];
    final int totalPoints = _trackPoints.length;
    
    // Show fewer markers for better visualization
    int step;
    if (totalPoints > 100) {
      step = (totalPoints / 5).ceil(); // About 5 markers for long tracks
    } else if (totalPoints > 50) {
      step = (totalPoints / 3).ceil(); // About 3 markers for medium tracks
    } else {
      step = (totalPoints / 2).ceil(); // About 2 markers for short tracks
    }
    
    // Ensure we don't have too many or too few markers
    step = step.clamp(5, 30);
    
    // Add intermediate markers
    for (int i = step; i < totalPoints - step; i += step) {
      markers.add(
        Marker(
          point: _trackPoints[i],
          width: 20,
          height: 20,
          child: Transform.rotate(
            angle: _calculateRotationAngle(i),
            child: _getShipIcon(_shipType, size: 15),
          ),
        ),
      );
    }
    
    return markers;
  }
  
  // Add this helper method to get the ship icon
  // Modify the _getShipIcon method to match the map_screen approach
  Widget _getShipIcon(String iconType, {double size = 30}) {
    try {
      return SvgPicture.asset(
        'assets/icons/$iconType.svg',
        width: size,
        height: size,
      );
    } catch (e) {
      // Fallback to a default icon if the SVG fails to load
      return Icon(
        Icons.directions_boat,
        size: size,
        color: Colors.blue,
      );
    }
  }
  
  // Calculate rotation angle based on direction of travel
  double _calculateRotationAngle(int pointIndex) {
    if (pointIndex <= 0 || pointIndex >= _trackPoints.length - 1) {
      return 0.0;
    }
    
    // Get previous and current points to determine direction
    final LatLng prevPoint = _trackPoints[pointIndex - 1];
    final LatLng currentPoint = _trackPoints[pointIndex];
    
    // Calculate angle in radians
    final double dx = currentPoint.longitude - prevPoint.longitude;
    final double dy = currentPoint.latitude - prevPoint.latitude;
    
    // Convert to proper rotation angle (atan2 returns angle in radians)
    // We add pi/2 (90 degrees) to adjust for the ship icon orientation
    return dx == 0 && dy == 0 ? 0.0 : atan2(dy, dx) + (3.14159 / 2);
  }
}