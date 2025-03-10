
import 'package:flutter/material.dart';
import 'dart:collection';

class NotificationService with ChangeNotifier {
  static const int maxMessages = 100;
  final Queue<Map<String, dynamic>> _alertMessages = Queue();
  final Queue<Map<String, dynamic>> _dangerMessages = Queue();

  void addAlertMessage(String message) {
    if (_alertMessages.length >= maxMessages) {
      _alertMessages.removeFirst();
    }
    final messageData = {
      'message': message,
      'timestamp': DateTime.now(),
    };
    _alertMessages.add(messageData);
    print("Added alert message: $message"); // Debug log
    notifyListeners();
  }

  void addDangerMessage(String message) {
    if (_dangerMessages.length >= maxMessages) {
      _dangerMessages.removeFirst();
    }
    final messageData = {
      'message': message,
      'timestamp': DateTime.now(),
    };
    _dangerMessages.add(messageData);
    print("Added danger message: $message"); // Debug log
    notifyListeners();
  }
  void removeAlertMessage(int index) {
    if (index >= 0 && index < _alertMessages.length) {
      final tempList = _alertMessages.toList();
      tempList.removeAt(index);
      _alertMessages.clear();
      _alertMessages.addAll(tempList);
      notifyListeners();
    }
  }
  void removeDangerMessage(int index) {
    if (index >= 0 && index < _dangerMessages.length) {
      final tempList = _dangerMessages.toList();
      tempList.removeAt(index);
      _dangerMessages.clear();
      _dangerMessages.addAll(tempList);
      notifyListeners();
    }
  }
  void clearAlertMessages() {
    _alertMessages.clear();
    notifyListeners();
  }
  void refreshMessages() {
    notifyListeners();
  }
  void clearMessages() {
    _alertMessages.clear();
    _dangerMessages.clear();
    notifyListeners(); // Perbarui UI
  }
  List<Map<String, dynamic>> get alertMessages => _alertMessages.toList();
  List<Map<String, dynamic>> get dangerMessages => _dangerMessages.toList();

  void clearDangerMessages() {}
}