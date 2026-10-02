import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/app/app_env.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/auth/presentation/widgets/login_brand_panel.dart';

// Login untuk semua role. Toko dan tampilan ikut akun yang login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = context.read<SessionController>();
    if (session.busy) return;
    final error = await session.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionController, bool>((s) => s.busy);

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 5, child: LoginBrandPanel()),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _form(busy),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Masuk ke Dashboard', style: AppTextStyle.h1),
        Text(
          'Gunakan akun kasir, admin, atau mitra Barberstuff.',
          style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
        ),
        const SizedBox(height: 24),
        const Text('Email', style: AppTextStyle.label),
        const SizedBox(height: 6),
        TextField(
          controller: _email,
          autofocus: true,
          enabled: !busy,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyle.body,
          decoration: const InputDecoration(hintText: 'nama@barberstuff.id'),
          onChanged: (_) => setState(() => _error = null),
        ),
        const SizedBox(height: 14),
        const Text('Password', style: AppTextStyle.label),
        const SizedBox(height: 6),
        TextField(
          controller: _password,
          obscureText: _obscure,
          enabled: !busy,
          style: AppTextStyle.body,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Lihat password' : 'Sembunyikan password',
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.dangerSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppColor.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: AppTextStyle.label.copyWith(color: AppColor.danger),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColor.surface,
                    ),
                  )
                : const Icon(Icons.login, size: 18),
            label: Text(busy ? 'Menghubungkan…' : 'Masuk'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_outlined,
              size: 14,
              color: AppColor.inkFaint,
            ),
            const SizedBox(width: 6),
            Text(
              Uri.parse(AppEnv.baseUrl).host,
              style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
            ),
          ],
        ),
      ],
    );
  }
}
