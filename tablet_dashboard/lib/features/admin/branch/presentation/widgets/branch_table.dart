import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_retry_view.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/app_search_field.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';
import 'package:tablet_dashboard/shared/widgets/navigation/pagination_bar.dart';

// Kartu daftar di tab detail cabang: judul, cari, tombol tambah, urutan,
// lalu tabel dan halaman. Isi tabel diatur tab-nya lewat [rows]
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

  // DropdownChip urutan, opsional
  final Widget? sort;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyle.h3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: AppSearchField(
                      hint: searchHint,
                      initialValue: query,
                      onChanged: onQuery,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(addLabel),
              ),
              if (sort != null) ...[const SizedBox(width: 12), sort!],
            ],
          ),
          const SizedBox(height: 16),
          BranchTableHeader(labels: columns, flex: flex),
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

// Baris judul kolom berlatar abu-abu
class BranchTableHeader extends StatelessWidget {
  const BranchTableHeader({
    super.key,
    required this.labels,
    required this.flex,
  });

  final List<String> labels;
  final List<int> flex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: BranchTableCells(
        flex: flex,
        children: [
          for (final label in labels)
            Text(
              label,
              style: AppTextStyle.label.copyWith(
                fontSize: 11,
                color: AppColor.inkSoft,
              ),
            ),
        ],
      ),
    );
  }
}

// Satu baris tabel dengan garis bawah. [highlight] = baris sedang diedit
class BranchTableRow extends StatelessWidget {
  const BranchTableRow({
    super.key,
    required this.flex,
    required this.children,
    this.highlight = false,
  });

  final List<int> flex;
  final List<Widget> children;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? AppColor.goldSoft : null,
        border: const Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: BranchTableCells(flex: flex, children: children),
    );
  }
}

// Kolom-kolom selebar [flex], kolom terakhir (aksi) rata kanan
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
                alignment: i == last
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: child,
              ),
            ),
          ),
      ],
    );
  }
}

// Tombol ikon kecil bergaris di kolom aksi (ubah / hapus)
class RowIconButton extends StatelessWidget {
  const RowIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppColor.gold,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColor.borderStrong),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 34,
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? AppColor.inkFaint : color,
            ),
          ),
        ),
      ),
    );
  }
}

// Ubah + hapus di ujung baris
class RowActions extends StatelessWidget {
  const RowActions({super.key, required this.onEdit, required this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RowIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Ubah',
          onTap: onEdit,
        ),
        const SizedBox(width: 8),
        RowIconButton(
          icon: Icons.delete_outline,
          tooltip: 'Hapus',
          color: AppColor.danger,
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

// Label Aktif / Tidak Aktif
class ActiveBadge extends StatelessWidget {
  const ActiveBadge({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
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
      // Di atas toast, bukan di dalam navigator cabang
      useRootNavigator: true,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final value in const [true, false])
          PopupMenuItem(
            value: value,
            child: Text(
              value ? 'Aktif' : 'Tidak Aktif',
              style: AppTextStyle.body.copyWith(
                color: value == active ? AppColor.gold : null,
                fontWeight: value == active ? FontWeight.w600 : null,
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
