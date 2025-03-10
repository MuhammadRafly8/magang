import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Error? _error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'An error occurred: ${details.exception}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'An error occurred: ${_error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return widget.child;
  }
}