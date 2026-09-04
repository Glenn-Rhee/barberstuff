import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/app/app_route.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/services/app_session.dart';
import 'package:mobile_barberstuff/core/services/google_auth_service.dart';
import 'package:mobile_barberstuff/features/auth/data/models/auth_provider_result.dart';
import 'package:mobile_barberstuff/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_barberstuff/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/google_sign_in_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:provider/provider.dart';

typedef GoogleSignInBuilder =
    Widget Function(bool isLoading, VoidCallback onPressed);

class GoogleSignInScope extends StatelessWidget {
  const GoogleSignInScope({super.key, required this.builder});

  final GoogleSignInBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoogleSignInProvider>(
      create: (BuildContext ctx) => GoogleSignInProvider(
        ctx.read<AuthRepository>(),
        ctx.read<GoogleAuthService>(),
        ctx.read<AppSession>(),
      ),
      child: _GoogleSignInHost(builder: builder),
    );
  }
}

class _GoogleSignInHost extends StatelessWidget {
  const _GoogleSignInHost({required this.builder});

  final GoogleSignInBuilder builder;

  Future<void> _run(BuildContext context, GoogleSignInProvider p) async {
    final bool ok = await p.signIn();
    if (!context.mounted) return;

    if (!ok) {
      if (p.error != null) {
        AppToast.show(
          context,
          message: p.error!.message(AppLocalizations.of(context)),
        );
      }
      return;
    }

    final AuthProviderResult result = p.result!;

    if (result.status == AuthProviderStatus.needCompleteProfile) {
      Navigator.of(context).pushNamed(
        AppRoute.completeProfile,
        arguments: CompleteProfileArgs(
          name: result.name,
          email: result.email,
          tempToken: result.tempToken ?? '',
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoute.home, (Route<dynamic> r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInProvider p = context.watch<GoogleSignInProvider>();

    return builder(p.isLoading, () {
      if (!p.isLoading) _run(context, p);
    });
  }
}
