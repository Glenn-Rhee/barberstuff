import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:tablet_dashboard/features/auth/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/auth/presentation/widgets/login_brand_panel.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/password_field.dart';

// Login untuk semua role. Toko dan tampilan ikut akun yang login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  String? _info;

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
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() {
      _error = error;
      _info = null;
    });
  }

  // Buka halaman reset, kalau berhasil email langsung diisi
  Future<void> _openReset() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(initialEmail: _email.text.trim()),
      ),
    );
    if (email == null || !mounted) return;
    _email.text = email;
    _password.clear();
    setState(() {
      _error = null;
      _info = 'Password berhasil diganti. Silakan masuk pakai password baru.';
    });
  }

  void _clearMessage(String _) => setState(() {
    _error = null;
    _info = null;
  });

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
        const FieldLabel('Email'),
        TextField(
          controller: _email,
          autofocus: true,
          enabled: !busy,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyle.body,
          decoration: const InputDecoration(hintText: 'example@gmail.com'),
          onChanged: _clearMessage,
        ),
        const SizedBox(height: 14),
        const FieldLabel('Password'),
        PasswordField(
          controller: _password,
          enabled: !busy,
          onChanged: _clearMessage,
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: busy ? null : _openReset,
            child: const Text('Reset password?'),
          ),
        ),
        if (_error != null) ...[
          MessageBox(message: _error!),
          const SizedBox(height: 14),
        ],
        if (_info != null) ...[
          MessageBox(message: _info!, success: true),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 6),
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
      ],
    );
  }
}
