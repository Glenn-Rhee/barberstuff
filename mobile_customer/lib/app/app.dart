import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/theme/app_theme.dart';
import 'package:mobile_barberstuff/features/notification/domain/entities/app_notification.dart';
import 'package:mobile_barberstuff/features/notification/presentation/provider/notification_provider.dart';
import 'package:mobile_barberstuff/features/notification/presentation/widgets/notification_text.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<LocalController, Locale>((c) => c.locale);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final l in supported) {
            if (l.languageCode == deviceLocale.languageCode) return l;
          }
        }
        return const Locale('id');
      },
      title: 'BarberStuff',
      theme: AppTheme.light,
      initialRoute: AppRoute.splash,
      onGenerateInitialRoutes: AppRoute.onGenerateInitialRoutes,
      onGenerateRoute: AppRoute.onGenerateRoute,

      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        final service = context.read<LocalNotificationService>();
        service.applyLabels(
          name: l10n.notificationChannelName,
          description: l10n.notificationChannelDescription,
        );

        context.read<NotificationProvider>().attachPresenter((
          AppNotification n,
        ) {
          service.show(
            title: notificationTitle(n.category, l10n),
            body: notificationBody(n.category, l10n),
          );
        });

        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
