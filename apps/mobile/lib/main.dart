import 'package:flutter/material.dart';

import 'package:saxpath_mobile/app.dart';
import 'package:saxpath_mobile/shared/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saxpath_mobile/core/constants/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase before anything else
  try {
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co', // Dummy URL to prevent crash
      anonKey: 'placeholder-key',
    );
  } catch (e) {
    // ignore: avoid_print
    print('Supabase init failed: $e');
  }

  await NotificationService().init();
  runApp(const SaxPathApp());
}
