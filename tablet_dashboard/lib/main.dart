import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tablet_dashboard/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kunci layar landscape + full screen seperti mesin kasir
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TabletDashboardApp());
}
