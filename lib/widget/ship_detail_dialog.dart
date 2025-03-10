import 'package:flutter/material.dart';
import '../model/ship_model.dart';

class ShipDetailDialog extends StatelessWidget {
  final ShipData shipData;

  const ShipDetailDialog({Key? key, required this.shipData}) : super(key: key);

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              ": $value",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shipData.name ?? 'Kapal Tidak Diketahui',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow("MMSI", shipData.id),
              _buildDetailRow("Tipe Kapal", shipData.type ?? 'Tidak Diketahui'),
              _buildDetailRow("Kecepatan", "${shipData.speed.toStringAsFixed(2)} knots"),
              _buildDetailRow("Koordinat", 
                "${shipData.latitude.toStringAsFixed(6)}, ${shipData.longitude.toStringAsFixed(6)}"),
              _buildDetailRow("Status Mesin", shipData.engineStatus ?? 'Tidak Diketahui'),
              _buildDetailRow("Status Navigasi", shipData.navStatus ?? 'Tidak Diketahui'),
              _buildDetailRow("Arah Haluan", "${shipData.trueHeading.toStringAsFixed(1)}°"),
              _buildDetailRow("COG", "${shipData.cog.toStringAsFixed(1)}°"),
              _buildDetailRow("Waktu Update", shipData.receivedOn.toString()),
            ],
          ),
        ),
      ),
    );
  }
}