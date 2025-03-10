import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/loading_service.dart';
import '../widget/loading_overlay.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<LoadingService>(
        builder: (BuildContext context, LoadingService loadingService, Widget? _) {
          try {
            return LoadingOverlay(
              isLoading: loadingService.isLoading,
              message: loadingService.message ?? 'Loading...',
              child: child,
            );
          } catch (e) {
            debugPrint('Error in AppWrapper: $e');
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}