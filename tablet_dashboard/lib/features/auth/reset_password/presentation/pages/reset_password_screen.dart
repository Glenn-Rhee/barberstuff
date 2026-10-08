import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/provider/session_controller.dart';
import 'package:tablet_dashboard/features/auth/login/presentation/widgets/login_brand_panel.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/message_box.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/password_field.dart';

// Reset password tanpa OTP, berhasil = balik ke login bawa email
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Batas minimal password dari backend
  static const _minLength = 5;

  late final _email = TextEditingController(text: widget.initialEmail);
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // Cek isian dulu sebelum kirim ke server
  String? _validate() {
    if (_email.text.trim().isEmpty || _oldPassword.text.isEmpty) {
      return 'Email dan password lama wajib diisi';
    }
    if (_newPassword.text.length < _minLength) {
      return 'Password baru minimal $_minLength karakter';
    }
    if (_newPassword.text != _confirm.text) {
      return 'Ulangi password baru belum sama';
    }
    if (_newPassword.text == _oldPassword.text) {
      return 'Password baru harus beda dengan password lama';
    }
    return null;
  }

  Future<void> _submit() async {
    final invalid = _validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim();
    final error = await context.read<SessionController>().resetPassword(
      email: email,
      oldPassword: _oldPassword.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, email);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: _form(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _busy ? null : () => Navigator.pop(context),
            icon: const AppIcon(AppAsset.backArrowIcon, size: 16),
            label: const Text('Kembali ke login'),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Reset Password', style: AppTextStyle.h1),
        Text(
          'Masukkan password lama atau password awal dari admin.',
          style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Email', required: true),
        TextField(
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyle.body,
          decoration: const InputDecoration(hintText: 'example@gmail.com'),
          onChanged: _clearError,
        ),
        const SizedBox(height: 14),
        const FieldLabel('Password lama', required: true),
        PasswordField(
          controller: _oldPassword,
          enabled: !_busy,
          onChanged: _clearError,
        ),
        const SizedBox(height: 14),
        const FieldLabel('Password baru', required: true),
        PasswordField(
          controller: _newPassword,
          enabled: !_busy,
          hint: 'Minimal $_minLength karakter',
          onChanged: _clearError,
        ),
        const SizedBox(height: 14),
        const FieldLabel('Ulangi password baru', required: true),
        PasswordField(
          controller: _confirm,
          enabled: !_busy,
          hint: 'Ketik ulang password baru',
          onChanged: _clearError,
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          MessageBox(message: _error!),
        ],
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColor.surface,
                    ),
                  )
                : const Icon(Icons.lock_reset, size: 18),
            label: Text(_busy ? 'Menyimpan…' : 'Simpan Password Baru'),
          ),
        ),
      ],
    );
  }
}
