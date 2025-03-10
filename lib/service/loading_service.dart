import 'package:flutter/material.dart';
import 'dart:async';

class LoadingService with ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  bool _debouncing = false;
  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<void> showLoading([String? message]) async {
    if (_debouncing) return;
    _debouncing = true;
    
    _isLoading = true;
    _message = message;
    notifyListeners();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _debouncing = false;
    });
  }
  
  void hideLoading() {
    _debounceTimer?.cancel();
    _isLoading = false;
    _message = null;
    _debouncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}