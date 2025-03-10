import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../service/heatmap_service.dart';

class HeatmapLayer extends StatelessWidget {
  final List<HeatPoint> heatPoints;
  
  const HeatmapLayer({
    Key? key,
    required this.heatPoints,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: heatPoints.map((point) {
        return Marker(
          point: point.point,
          width: 60 * point.intensity,
          height: 60 * point.intensity,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getHeatColor(point.intensity).withOpacity(0.7),
                  _getHeatColor(point.intensity).withOpacity(0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Color _getHeatColor(double intensity) {
    // Color gradient from blue (low) to red (high)
    if (intensity < 0.25) {
      return Colors.blue;
    } else if (intensity < 0.5) {
      return Colors.green;
    } else if (intensity < 0.75) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}