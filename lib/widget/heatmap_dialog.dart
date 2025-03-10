import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../service/heatmap_service.dart';

class HeatmapDialog extends StatefulWidget {
  const HeatmapDialog({Key? key}) : super(key: key);

  @override
  State<HeatmapDialog> createState() => _HeatmapDialogState();
}

class _HeatmapDialogState extends State<HeatmapDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _showHeatmap;

  @override
  void initState() {
    super.initState();
    final heatmapService = Provider.of<HeatmapService>(context, listen: false);
    _startDate = heatmapService.startDate;
    _endDate = heatmapService.endDate;
    _showHeatmap = heatmapService.showHeatmap;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vessel Heatmap Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Show Heatmap'),
                const Spacer(),
                Switch(
                  value: _showHeatmap,
                  onChanged: (value) {
                    setState(() {
                      _showHeatmap = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Select Date Range:'),
            const SizedBox(height: 8),
            ListTile(
              title: Text('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
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
        ElevatedButton(
          onPressed: () {
            final heatmapService = Provider.of<HeatmapService>(context, listen: false);
            heatmapService.toggleHeatmap(_showHeatmap);
            heatmapService.setDateRange(_startDate, _endDate);
            heatmapService.fetchHeatmapData();
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}