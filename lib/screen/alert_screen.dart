import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/notification_service.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});
  
  Future<void> _handleRefresh(BuildContext context, NotificationService service) async {
    try {
      service.refreshMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing messages: $e')),
      );
    }
  }
  
  Future<void> _handleClear(BuildContext context, NotificationService service) async {
    try {
      service.clearAlertMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing messages: $e')),
      );
    }
  }
  
  Future<void> _handleRemove(BuildContext context, NotificationService service, int index) async {
    try {
      service.removeAlertMessage(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing message: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/map'),
            ),
            title: const Text("Daftar Kapal di Area Terbatas"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _handleRefresh(context, notificationService),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _handleClear(context, notificationService),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daftar Kapal yang Masuk ke Area Terbatas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.blue, thickness: 2),
                const SizedBox(height: 10),
                Expanded(
                  child: (notificationService.alertMessages.isEmpty)
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("Tidak ada notifikasi."),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: notificationService.alertMessages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final messageData = notificationService.alertMessages[index];
                            final message = messageData['message'] as String;
                            final timestamp = messageData['timestamp'] as DateTime;
                            
                            return Dismissible(
                              key: Key('alert_$index'),
                              onDismissed: (direction) => _handleRemove(context, notificationService, index),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.warning, color: Colors.blue),
                                title: Text(message),
                                subtitle: Text(
                                  timestamp.toString().substring(0, 19),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          })
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