import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tablet_dashboard/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Handle landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TabletDashboardApp());
}
