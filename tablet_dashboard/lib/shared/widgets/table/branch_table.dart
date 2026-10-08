import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Kartu tabel di tab detail: judul, cari, tambah, urut, tabel, halaman
class BranchListCard extends StatelessWidget {
  const BranchListCard({
    super.key,
    required this.title,
    required this.searchHint,
    required this.query,
    required this.onQuery,
    required this.addLabel,
    required this.onAdd,
    required this.columns,
    required this.flex,
    required this.rows,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.page,
    required this.pageCount,
    required this.onPage,
    this.sort,
    this.headerColor = AppColor.goldSoft,
    this.endColumns = const {},
  });

  final String title;
  final String searchHint;
  final String query;
  final ValueChanged<String> onQuery;
  final String addLabel;
  final VoidCallback? onAdd;
  final List<String> columns;
  final List<int> flex;
  final List<Widget> rows;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;

  // Halaman mulai 1
  final int page;
  final int pageCount;
  final ValueChanged<int> onPage;

  // DropdownChip urutan, tampil setelah label "Urutkan:"
  final Widget? sort;
  final Color headerColor;

  // Kolom yang judulnya rata kanan, mis. harga
  final Set<int> endColumns;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: AppSearchField(
                        hint: searchHint,
                        initialValue: query,
                        onChanged: onQuery,
                        fillColor: AppColor.surfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  elevation: 2,
                  shadowColor: AppColor.gold.withValues(alpha: 0.4),
                ),
                icon: const AppIcon(AppAsset.plusIcon, size: 14),
                label: Text(addLabel),
              ),
              if (sort != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Urutkan:',
                  style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
                ),
                const SizedBox(width: 8),
                sort!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          BranchTableHeader(
            labels: columns,
            flex: flex,
            color: headerColor,
            endColumns: endColumns,
          ),
          if (loading)
            SkeletonRows(flex: flex, count: 4, rowHeight: 60)
          else if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ErrorRetryView(
                title: 'Gagal memuat data',
                message: error!,
                onRetry: onRetry,
              ),
            )
          else if (rows.isEmpty)
            EmptyState(
              icon: Icons.inbox_outlined,
              title: emptyTitle,
              message: emptyMessage,
            )
          else
            ...rows,
          if (!loading && error == null && pageCount > 1) ...[
            const SizedBox(height: 16),
            PaginationBar(
              page: page - 1,
              pageCount: pageCount,
              onChanged: (value) => onPage(value + 1),
            ),
          ],
        ],
      ),
    );
  }
}

// Baris judul kolom, latar krem kecuali diatur [color]
class BranchTableHeader extends StatelessWidget {
  const BranchTableHeader({
    super.key,
    required this.labels,
    required this.flex,
    this.color = AppColor.goldSoft,
    this.endColumns = const {},
  });

  final List<String> labels;
  final List<int> flex;
  final Color color;
  final Set<int> endColumns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BranchTableCells(
        flex: flex,
        children: [
          for (final (i, label) in labels.indexed)
            if (endColumns.contains(i))
              Align(alignment: Alignment.centerRight, child: _label(label))
            else
              _label(label),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppTextStyle.label.copyWith(fontSize: 11, color: AppColor.inkSoft),
  );
}

// Satu baris tabel dengan garis bawah. [color] = latar, mis. baris diedit
class BranchTableRow extends StatelessWidget {
  const BranchTableRow({
    super.key,
    required this.flex,
    required this.children,
    this.color,
  });

  final List<int> flex;
  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        border: const Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: BranchTableCells(flex: flex, children: children),
    );
  }
}

// Kolom-kolom selebar [flex], kolom terakhir (aksi) rata tengah
class BranchTableCells extends StatelessWidget {
  const BranchTableCells({
    super.key,
    required this.flex,
    required this.children,
  });

  final List<int> flex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final last = children.length - 1;
    return Row(
      children: [
        for (final (i, child) in children.indexed)
          Expanded(
            flex: flex[i],
            child: Padding(
              padding: EdgeInsets.only(right: i == last ? 0 : 12),
              child: Align(
                alignment: i == last ? Alignment.center : Alignment.centerLeft,
                child: child,
              ),
            ),
          ),
      ],
    );
  }
}

// Tombol ikon kecil di kolom aksi (ubah / hapus), ikon aset berwarna
class RowIconButton extends StatelessWidget {
  const RowIconButton({
    super.key,
    required this.asset,
    required this.tooltip,
    required this.onTap,
    this.bordered = true,
    this.background = AppColor.surface,
  });

  final String asset;
  final String tooltip;
  final VoidCallback? onTap;
  final bool bordered;

  // Mis. merah muda untuk tombol hapus
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: bordered
              ? const BorderSide(color: AppColor.borderStrong)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox.square(
            dimension: bordered ? 34 : 30,
            child: Center(
              child: Opacity(
                opacity: onTap == null ? 0.4 : 1,
                child: AppIcon(asset, size: 16, tint: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Ubah + hapus di ujung baris. [editAsset] = pensil per tab
class RowActions extends StatelessWidget {
  const RowActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.editAsset = AppAsset.editServiceIcon,
    this.bordered = true,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String editAsset;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RowIconButton(
          asset: editAsset,
          tooltip: 'Ubah',
          bordered: bordered,
          onTap: onEdit,
        ),
        SizedBox(width: bordered ? 8 : 2),
        RowIconButton(
          asset: AppAsset.trashIcon,
          tooltip: 'Hapus',
          bordered: bordered,
          onTap: onDelete,
        ),
      ],
    );
  }
}

// Simpan + Batal di ujung baris yang sedang diedit
class RowEditActions extends StatelessWidget {
  const RowEditActions({
    super.key,
    required this.busy,
    required this.onSave,
    required this.onCancel,
  });

  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FilledButton(
            onPressed: busy ? null : onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size(72, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.gold,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton(
            onPressed: busy ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.ink,
              side: const BorderSide(color: AppColor.borderStrong),
              minimumSize: const Size(64, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Batal'),
          ),
        ),
      ],
    );
  }
}

// Label Aktif hijau / Tidak Aktif merah. [gold] = gaya tab Capster
class ActiveBadge extends StatelessWidget {
  const ActiveBadge({super.key, required this.active, this.gold = false});

  final bool active;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    if (gold && active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.gold,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Aktif',
          style: AppTextStyle.label.copyWith(color: AppColor.surface),
        ),
      );
    }
    return active
        ? const StatusBadge(
            label: 'Aktif',
            color: AppColor.success,
            background: AppColor.successSoft,
          )
        : const StatusBadge(
            label: 'Tidak Aktif',
            color: AppColor.danger,
            background: AppColor.dangerSoft,
          );
  }
}

// Pilihan Aktif / Tidak Aktif saat baris diedit
class ActiveSelect extends StatelessWidget {
  const ActiveSelect({
    super.key,
    required this.active,
    required this.onChanged,
  });

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      tooltip: 'Ubah status',
      menuPadding: EdgeInsets.zero,
      // Di atas toast, bukan di dalam navigator cabang
      useRootNavigator: true,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final value in const [true, false])
          // Pilihan yang sedang dipakai berlatar emas
          PopupMenuItem(
            value: value,
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              color: value == active ? AppColor.gold : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                value ? 'Aktif' : 'Tidak Aktif',
                style: AppTextStyle.body.copyWith(
                  color: value == active ? AppColor.surface : AppColor.ink,
                  fontWeight: value == active ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.gold),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                active ? 'Aktif' : 'Tidak Aktif',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

// Input ringkas di dalam baris tabel
class RowTextField extends StatelessWidget {
  const RowTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: AppTextStyle.body,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: AppColor.surface,
        suffixIcon: suffix,
      ),
    );
  }
}
