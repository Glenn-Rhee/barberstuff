import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_route.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberStuff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoute.splash,
      onGenerateRoute: AppRoute.onGenerateRoute,
    );
  }
}
