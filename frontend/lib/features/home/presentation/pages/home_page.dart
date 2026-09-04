import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);

    await context.read<AppSession>().clearSession();

    navigator.pushNamedAndRemoveUntil(
      AppRoute.chooseLogin,
      (Route<dynamic> r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.ink,
        elevation: 0,
        actions: <Widget>[
          Text(
            "Halo, ",
            style: AppTextStyle.headlineSmall,
            
            
          ),

          IconButton(

            onPressed: () => _logout(context),
            tooltip: l10n.commonLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColor.ink),
          ),
        ],
      ),

      body: Center(
        child: Text(
          l10n.comingSoonTitle,
          style: AppTextStyle.headlineMedium.copyWith(color: AppColor.inkSoft),
        ),
      ),
    );
  }
}
