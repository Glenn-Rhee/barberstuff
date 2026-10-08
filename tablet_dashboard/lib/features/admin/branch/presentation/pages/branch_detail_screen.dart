import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/pages/branch_edit_screen.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/account_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_sync.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/capster_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/service_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/account_tab.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_profile_card.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/capster_tab.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/map_tab.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/service_tab.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/shared/dialogs/confirm_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/back_text_button.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_tabs.dart';

// Detail cabang: profil + tab Capster, Service, Paket, Maps, Role Akun
class BranchDetailScreen extends StatelessWidget {
  const BranchDetailScreen({super.key, required this.branch});

  // Data awal dari daftar, langsung diganti hasil GET /store/{id}
  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final api = context.read<BranchApi>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BranchDetailController(api, branch)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => CapsterListController(api, branch.id)..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceListController(api, branch.id)..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => PackageListController(api, branch.id)..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountListController(api, branch.id)..refresh(),
        ),
      ],
      child: const _BranchDetailView(),
    );
  }
}

class _BranchDetailView extends StatefulWidget {
  const _BranchDetailView();

  @override
  State<_BranchDetailView> createState() => _BranchDetailViewState();
}

class _BranchDetailViewState extends State<_BranchDetailView> {
  static const _tabs = [
    'Capster',
    'Service',
    'Paket',
    'Maps Toko',
    'Role Akun',
  ];

  int _tab = 0;
  bool _deleting = false;

  Future<void> _edit() async {
    final detail = context.read<BranchDetailController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: detail,
          child: const BranchEditScreen(),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final detail = context.read<BranchDetailController>();
    final name = detail.branch.name;
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus $name?',
      message:
          'Cabang hilang dari aplikasi pelanggan, akun kasir & mitra-nya '
          'tidak bisa login lagi.',
      confirmLabel: 'Hapus Cabang',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _deleting = true);
    final error = await detail.delete();
    if (!mounted) return;
    setState(() => _deleting = false);
    if (error != null) {
      AppToast.show(context, error, error: true);
      return;
    }
    BranchSync.stores(context);
    AppToast.show(context, 'Cabang $name dihapus');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<BranchDetailController>();

    return Material(
      color: AppColor.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: BackTextButton(),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Breadcrumb(),
                      const SizedBox(height: 4),
                      Text(
                        detail.branch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h1.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _deleting ? null : _delete,
                  style: AppButtonStyle.dangerOutlined,
                  icon: _deleting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.danger,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus Cabang'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _deleting ? null : _edit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Cabang'),
                ),
              ],
            ),
            if (detail.error != null) ...[
              const SizedBox(height: 16),
              ErrorBar(
                message: 'Data terbaru gagal dimuat: ${detail.error}',
                onRetry: detail.load,
              ),
            ],
            const SizedBox(height: 20),
            const BranchProfileCard(),
            const SizedBox(height: 24),
            PageTabs(
              tabs: _tabs,
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 16),
            switch (_tab) {
              0 => const CapsterTab(),
              1 => const ServiceTab(
                key: ValueKey('service'),
                type: ServiceType.service,
              ),
              2 => const ServiceTab(
                key: ValueKey('package'),
                type: ServiceType.package,
              ),
              3 => MapTab(onEdit: _edit),
              _ => const AccountTab(),
            },
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          child: Text(
            'Kelola Cabang',
            style: AppTextStyle.label.copyWith(color: AppColor.inkSoft),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: AppColor.inkSoft),
        Text(
          'Detail Cabang',
          style: AppTextStyle.label.copyWith(color: AppColor.gold),
        ),
      ],
    );
  }
}
