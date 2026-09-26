import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_text_style.dart';
import '../provider/session_controller.dart';

/// Signs the cashier in against `/auth/login/credential`. The store they work at
/// comes from their profile, so there is nothing to pick here.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final error = await session.signIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionController, bool>((s) => s.busy);

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 5, child: _BrandPanel()),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: _form(busy)),
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
        const Text('Masuk ke Kasir', style: AppTextStyle.pageTitle),
        Text(
          'Gunakan akun kasir Barberstuff. Cabang mengikuti akun Anda.',
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
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
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
            decoration: BoxDecoration(color: AppColor.dangerSoft, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18, color: AppColor.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!, style: AppTextStyle.label.copyWith(color: AppColor.danger)),
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
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.login, size: 18),
            label: Text(busy ? 'Menghubungkan…' : 'Masuk'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_outlined, size: 14, color: AppColor.inkFaint),
            const SizedBox(width: 6),
            Text(Uri.parse(ApiClient.defaultBaseUrl).host, style: AppTextStyle.caption),
          ],
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  static const _points = [
    (Icons.point_of_sale_outlined, 'Pesanan langsung & dari reservasi'),
    (Icons.print_outlined, 'Struk otomatis ke printer 58mm'),
    (Icons.insights_outlined, 'Rekap kas & shift harian'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.sidebar,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Image.asset('assets/images/logo_glyph.png', color: AppColor.sidebar),
                ),
                const SizedBox(width: 14),
                Text(
                  'KASIR',
                  style: AppTextStyle.overline.copyWith(color: AppColor.gold, fontSize: 12, letterSpacing: 3),
                ),
              ],
            ),
            const Spacer(),
            Image.asset('assets/images/receipt_logo.png', color: Colors.white, width: 300),
            const SizedBox(height: 16),
            Text(
              'Kasir untuk layanan, reservasi, dan pembukuan harian toko.',
              style: AppTextStyle.body.copyWith(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 28),
            for (final (icon, label) in _points)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColor.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label, style: AppTextStyle.body.copyWith(color: AppColor.sidebarMuted)),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Text('Panda PRJ-R58D · kertas 58mm', style: AppTextStyle.caption.copyWith(color: AppColor.sidebarMuted)),
          ],
        ),
      ),
    );
  }
}
