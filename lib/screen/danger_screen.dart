import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/notification_service.dart';
import '../utils/error_handler.dart';

class DangerScreen extends StatelessWidget {
  const DangerScreen({super.key});
  
  Future<void> _handleRefresh(BuildContext context, NotificationService service) async {
    try {
      service.refreshMessages();
    } catch (e) {
      ErrorHandler.showSnackBar(context, 'Error refreshing messages', isError: true);
    }
  }
  
  Future<void> _handleClear(BuildContext context, NotificationService service) async {
    try {
      service.clearDangerMessages();
    } catch (e) {
      ErrorHandler.showSnackBar(context, 'Error clearing messages', isError: true);
    }
  }
  
  Future<void> _handleRemove(BuildContext context, NotificationService service, int index) async {
    try {
      service.removeDangerMessage(index);
    } catch (e) {
      ErrorHandler.showSnackBar(context, 'Error removing message', isError: true);
    }
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text("Tidak ada notifikasi."),
        ],
      ),
    );
  }
  
  Widget _buildMessageList(BuildContext context, NotificationService service) {
    return ListView.builder(
      itemCount: service.dangerMessages.length,
      itemBuilder: (context, index) {
        final message = service.dangerMessages[index];
        return Dismissible(
          key: Key('danger_${message['timestamp']}'),
          onDismissed: (_) => _handleRemove(context, service, index),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: const Icon(Icons.dangerous, color: Colors.red),
            title: Text(message['message']),
            subtitle: Text(
              message['timestamp'].toString().substring(0, 19),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, service, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/map'),
            ),
            title: const Text("Daftar Kapal di Area Terlarang"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _handleRefresh(context, service),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _handleClear(context, service),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daftar Kapal yang Masuk ke Area Terlarang",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.red, thickness: 2),
                const SizedBox(height: 10),
                Expanded(
                  child: service.dangerMessages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessageList(context, service),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}