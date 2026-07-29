import 'package:flutter/material.dart';
import 'app.dart';
import 'core/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Never let notification setup block the app from launching.
  try {
    await NotificationService.init();
  } catch (_) {
    // Notifications are best-effort; the app must still start.
  }
  runApp(const DieterApp());
}
