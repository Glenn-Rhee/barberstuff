import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/core/utils/thousands_formatter.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/provider/shift_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';
import 'package:tablet_dashboard/shared/widgets/form/money_field.dart';

// Jenis catatan kas
enum CashCategory {
  expense('Pengeluaran'),
  income('Pemasukan');

  const CashCategory(this.label);

  final String label;
}

// Catat Kas: pengeluaran, atau pemasukan dari booking progress
Future<void> showCashEntryDialog(
  BuildContext context, {
  CashCategory initial = CashCategory.expense,
}) async {
  final shift = context.read<ShiftController>();
  if (!shift.isOpen) {
    AppToast.show(
      context,
      shift.enabled
          ? 'Buka shift dulu sebelum mencatat kas'
          : shift.closedMessage,
      error: true,
    );
    return;
  }

  String? message;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _CashEntryDialog(initial: initial, onSaved: (text) => message = text),
  );
  if (saved != true || !context.mounted) return;
  context.read<BookingsController>().refresh();
  context.read<DashboardController>().refresh();
  AppToast.show(context, message ?? 'Kas dicatat');
}

class _CashEntryDialog extends StatefulWidget {
  const _CashEntryDialog({required this.initial, required this.onSaved});

  final CashCategory initial;
  final ValueChanged<String> onSaved;

  @override
  State<_CashEntryDialog> createState() => _CashEntryDialogState();
}

class _CashEntryDialogState extends State<_CashEntryDialog> {
  // Backend menolak nominal di bawah Rp 1.000
  static const _minAmount = 1000;

  late CashCategory _category = widget.initial;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _now = DateTime.now();

  // Pemasukan
  List<Booking> _bookings = const [];
  bool _loadingBookings = false;
  String? _bookingError;
  Booking? _booking;
  PaymentType _method = PaymentType.cash;

  int get _value => ThousandsFormatter.parse(_amount.text);

  @override
  void initState() {
    super.initState();
    if (_category == CashCategory.income) _loadBookings();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  // Booking yang sedang dilayani (progress) = yang bisa dibayar
  Future<void> _loadBookings() async {
    setState(() {
      _loadingBookings = true;
      _bookingError = null;
    });
    try {
      final result = await context.read<BookingApi>().bookings(
        status: BookingStatus.progress,
        limit: 50,
      );
      if (mounted) setState(() => _bookings = result.items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _bookingError = e.message);
    } finally {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  void _setCategory(CashCategory? value) {
    if (value == null || value == _category) return;
    setState(() => _category = value);
    if (value == CashCategory.income && _bookings.isEmpty) _loadBookings();
  }

  bool get _canSubmit => switch (_category) {
    CashCategory.expense =>
      _value >= _minAmount && _note.text.trim().isNotEmpty,
    CashCategory.income => _booking != null,
  };

  Future<String?> _submit() async {
    final shift = context.read<ShiftController>();
    final note = _note.text.trim();
    switch (_category) {
      case CashCategory.expense:
        final error = await shift.recordCashOut(amount: _value, title: note);
        if (error == null) {
          widget.onSaved('Pengeluaran ${PriceFormat.full(_value)} dicatat');
        }
        return error;
      case CashCategory.income:
        final booking = _booking!;
        final error = await shift.recordSale(
          amount: booking.total,
          paymentType: _method,
          title: 'Booking ${booking.customer.name}',
          bookingId: booking.id,
          description: note.isEmpty ? null : note,
        );
        if (error == null) {
          widget.onSaved(
            'Pemasukan ${PriceFormat.full(booking.total)} dari '
            '${booking.customer.name} dicatat',
          );
        }
        return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = _category == CashCategory.income;

    return AppFormDialog(
      title: 'Catat Kas',
      subtitle: 'Masukkan pengeluaran/pemasukan operasional toko',
      width: 560,
      canSubmit: _canSubmit,
      onSubmit: _submit,
      children: [
        _pair(
          [
            const FieldLabel('Tanggal & Waktu'),
            InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                '${DateFormatId.compactDate(_now)}, ${DateFormatId.time(_now)}',
                style: AppTextStyle.body,
              ),
            ),
          ],
          [
            const FieldLabel('Kategori', required: true),
            DropdownButtonFormField<CashCategory>(
              initialValue: _category,
              style: AppTextStyle.body.copyWith(color: AppColor.ink),
              items: [
                for (final c in CashCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: _setCategory,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (income) ..._incomeFields() else ..._expenseFields(),
        const SizedBox(height: 14),
        FieldLabel('Keterangan', required: !income),
        TextField(
          controller: _note,
          minLines: 2,
          maxLines: 2,
          style: AppTextStyle.body,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: income
                ? 'Catatan tambahan (opsional)'
                : 'Contoh: beli air mineral dan tisu',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // Dua kolom berdampingan biar modal muat di layar 800dp
  static Widget _pair(List<Widget> left, List<Widget> right) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: left,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: right,
        ),
      ),
    ],
  );

  List<Widget> _expenseFields() => [
    _pair(
      [
        const FieldLabel('Nominal', required: true),
        MoneyField(controller: _amount, onChanged: (_) => setState(() {})),
        const SizedBox(height: 6),
        Text(
          'Minimal ${PriceFormat.full(_minAmount)}',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        ),
      ],
      [
        const FieldLabel('Metode Pembayaran', required: true),
        // Kas keluar diambil dari laci, jadi selalu tunai
        const Pill(
          label: 'Tunai',
          icon: AppAsset.cashIcon,
          selected: true,
          style: PillStyle.soft,
          height: 48,
          onTap: null,
        ),
      ],
    ),
  ];

  List<Widget> _incomeFields() {
    final booking = _booking;
    return [
      const FieldLabel('Booking yang dibayar', required: true),
      if (_loadingBookings)
        const Skeleton(child: SkeletonBox(height: 48, radius: 10))
      else if (_bookingError != null)
        Text(
          _bookingError!,
          style: AppTextStyle.caption.copyWith(color: AppColor.danger),
        )
      else if (_bookings.isEmpty)
        Text(
          'Belum ada booking yang sedang dilayani.',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        )
      else
        DropdownButtonFormField<Booking>(
          initialValue: booking,
          isExpanded: true,
          hint: const Text('Pilih booking'),
          style: AppTextStyle.body.copyWith(color: AppColor.ink),
          items: [
            for (final b in _bookings)
              DropdownMenuItem(
                value: b,
                child: Text(
                  '${b.customer.name} · '
                  '${b.services.map((s) => s.item.name).join(', ')}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _booking = value),
        ),
      const SizedBox(height: 14),
      _pair(
        [
          const FieldLabel('Nominal'),
          InputDecorator(
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              suffixText: 'Total booking',
            ),
            child: Text(
              booking == null ? '-' : PriceFormat.plain(booking.total),
              style: AppTextStyle.bodyBold,
            ),
          ),
        ],
        [
          const FieldLabel('Metode Pembayaran', required: true),
          Row(
            children: [
              for (final (index, method) in PaymentType.values.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: Pill(
                    label: method == PaymentType.cash ? 'Tunai' : 'Transfer',
                    icon: method == PaymentType.cash
                        ? AppAsset.cashIcon
                        : AppAsset.cashlessIcon,
                    style: PillStyle.soft,
                    height: 48,
                    selected: _method == method,
                    onTap: () => setState(() => _method = method),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ];
  }
}
