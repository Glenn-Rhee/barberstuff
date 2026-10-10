import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/admin/branch_create/presentation/pages/branch_create_screen.dart';
import 'package:tablet_dashboard/features/admin/branch_detail/presentation/pages/branch_detail_screen.dart';
import 'package:tablet_dashboard/features/admin/branch_detail/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch_edit/presentation/pages/branch_edit_screen.dart';
import 'package:tablet_dashboard/features/admin/branch_list/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch_list/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch_list/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch_list/presentation/widgets/branch_card.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Mengelola Cabang: grid cabang, cari, tambah, detail, edit
class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  static const _spacing = 16.0;

  @override
  void initState() {
    super.initState();
    // Data terbaru tiap halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final list = context.read<BranchListController>();
      list.refresh(silent: list.all.isNotEmpty);
    });
  }

  // Buka halaman turunan, daftar dimuat ulang saat kembali
  Future<void> _open(Widget page) async {
    final list = context.read<BranchListController>();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    list.refresh(silent: true);
  }

  void _edit(Branch branch) => _open(
    ChangeNotifierProvider(
      create: (context) =>
          BranchDetailController(context.read<BranchApi>(), branch)..load(),
      child: const BranchEditScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final list = context.watch<BranchListController>();

    return Material(
      color: AppColor.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Mengelola Cabang',
              subtitle: 'Kelola informasi dan layanan di setiap cabang.',
              actions: [
                SizedBox(
                  width: 260,
                  child: AppSearchField(
                    hint: 'Cari cabang...',
                    initialValue: list.query,
                    onChanged: list.setQuery,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _open(const BranchCreateScreen()),
                  style: FilledButton.styleFrom(
                    foregroundColor: AppColor.ink,
                    elevation: 2,
                    shadowColor: AppColor.gold.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  icon: const AppIcon(AppAsset.plusIcon, size: 14),
                  label: const Text('Tambah Cabang'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _body(list)),
            if (!list.loading && list.error == null && list.totalPages > 1) ...[
              const SizedBox(height: 12),
              PaginationBar(
                page: list.page - 1,
                pageCount: list.totalPages,
                onChanged: (page) => list.setPage(page + 1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body(BranchListController list) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 3 : 2;
        // 2 baris pas satu layar seperti desain, layar pendek = bisa scroll
        final cardHeight = ((constraints.maxHeight - _spacing) / 2).clamp(
          BranchCard.minHeight,
          BranchCard.maxHeight,
        );
        if (list.loading) {
          return SkeletonGrid(
            crossAxisCount: columns,
            mainAxisExtent: cardHeight,
            count: list.pageSize,
            spacing: _spacing,
          );
        }
        if (list.error != null) {
          return ErrorRetryView(
            title: 'Gagal memuat cabang',
            message: list.error!,
            onRetry: list.refresh,
          );
        }
        final branches = list.visible;
        if (branches.isEmpty) {
          return EmptyState(
            icon: Icons.storefront_outlined,
            title: list.all.isEmpty
                ? 'Belum ada cabang'
                : 'Cabang tidak ditemukan',
            message: list.all.isEmpty
                ? 'Tambah cabang pertama lewat tombol Tambah Cabang.'
                : 'Coba kata kunci lain.',
          );
        }
        return RefreshIndicator(
          onRefresh: list.refresh,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: cardHeight,
              crossAxisSpacing: _spacing,
              mainAxisSpacing: _spacing,
            ),
            itemCount: branches.length,
            itemBuilder: (_, i) => BranchCard(
              branch: branches[i],
              onDetail: () => _open(BranchDetailScreen(branch: branches[i])),
              onEdit: () => _edit(branches[i]),
            ),
          ),
        );
      },
    );
  }
}
