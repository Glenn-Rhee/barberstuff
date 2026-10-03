import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/features/admin/branch/data/branch_api.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/pages/branch_create_screen.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/pages/branch_detail_screen.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/pages/branch_edit_screen.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_card.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/refresh_button.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/form/dropdown_chip.dart';
import 'package:tablet_dashboard/shared/widgets/layout/page_header.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Halaman Mengelola Cabang: grid semua cabang, cari, tambah cabang,
// lalu masuk ke detail atau edit
class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
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
                  width: 240,
                  child: AppSearchField(
                    hint: 'Cari cabang...',
                    initialValue: list.query,
                    onChanged: list.setQuery,
                  ),
                ),
                DropdownChip<BranchSort>(
                  value: list.sort,
                  options: BranchSort.values,
                  labelOf: (s) => s.label,
                  onChanged: list.setSort,
                ),
                RefreshButton(onRefresh: list.refresh),
                FilledButton.icon(
                  onPressed: () => _open(const BranchCreateScreen()),
                  icon: const Icon(Icons.add, size: 18),
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
        final columns = constraints.maxWidth >= 880 ? 3 : 2;
        if (list.loading) {
          return SkeletonGrid(
            crossAxisCount: columns,
            mainAxisExtent: BranchCard.height,
            count: list.pageSize,
            spacing: 16,
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
              mainAxisExtent: BranchCard.height,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
