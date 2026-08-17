import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `LocationErrorWidget`. Shown whenever the compass
/// can't run yet: GPS disabled, permission denied/denied-forever, or a
/// runtime sensor error.
class CompassStatusMessage extends StatelessWidget {
  const CompassStatusMessage({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.location_off, size: 120, color: errorColor),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel ?? tr('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}
