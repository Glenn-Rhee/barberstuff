import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/theme/app_button_style.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/date_format.dart';
import 'package:tablet_dashboard/core/utils/price_format.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/features/cashier/customer/domain/entities/customer_profile.dart';
import 'package:tablet_dashboard/features/cashier/dashboard/presentation/provider/dashboard_controller.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/cart_item_tile.dart';
import 'package:tablet_dashboard/features/cashier/reservation/data/booking_api.dart';
import 'package:tablet_dashboard/features/cashier/reservation/domain/entities/booking_slot.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/provider/bookings_controller.dart';
import 'package:tablet_dashboard/features/cashier/reservation/presentation/widgets/service_picker_dialog.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/provider/store_controller.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/pill.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/skeleton.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';

// Reservasi pelanggan: tanggal, jam & capster kosong, layanan (tiap item 1x)
Future<void> showNewReservationDialog(
  BuildContext context,
  CustomerProfile customer,
) async {
  String? created;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _NewReservationDialog(
      customer: customer,
      onCreated: (label) => created = label,
    ),
  );
  if (saved != true || !context.mounted) return;
  context.read<BookingsController>().refresh();
  context.read<DashboardController>().refresh();
  AppToast.show(context, 'Reservasi ${customer.name} dibuat · $created');
}

class _NewReservationDialog extends StatefulWidget {
  const _NewReservationDialog({
    required this.customer,
    required this.onCreated,
  });

  final CustomerProfile customer;
  final ValueChanged<String> onCreated;

  @override
  State<_NewReservationDialog> createState() => _NewReservationDialogState();
}

class _NewReservationDialogState extends State<_NewReservationDialog> {
  // Pilihan tanggal: hari ini sampai 6 hari ke depan
  static const _days = 7;

  late DateTime _date = _today;
  List<BookingSlot> _slots = const [];
  bool _loading = false;
  String? _error;
  BookingSlot? _slot;
  String? _capsterId;
  final List<ServiceItem> _services = [];

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
      _slot = null;
      _capsterId = null;
    });
    try {
      final slots = await context.read<BookingApi>().slots(
        storeId: context.read<StoreController>().storeId,
        date: _date,
      );
      if (mounted) setState(() => _slots = slots);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Item yang sudah dipilih tidak muncul lagi di pemilih
  Future<void> _addService() async {
    final item = await showServicePicker(
      context,
      excludeIds: {for (final s in _services) s.id},
    );
    if (item != null && mounted) setState(() => _services.add(item));
  }

  void _pickDate(DateTime value) {
    if (value == _date) return;
    _date = value;
    _loadSlots();
  }

  // "14:30" di tanggal terpilih
  DateTime? get _scheduledAt {
    final slot = _slot;
    if (slot == null) return null;
    final parts = slot.time.split(':');
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Future<String?> _submit() async {
    final at = _scheduledAt;
    try {
      await context.read<BookingApi>().createBooking(
        storeId: context.read<StoreController>().storeId,
        capsterId: _capsterId!,
        serviceIds: [for (final s in _services) s.id],
        bookingDate: at!,
        customerId: widget.customer.id,
        scheduled: true,
      );
      widget.onCreated(
        '${DateFormatId.shortDate(at)} ${DateFormatId.time(at)}',
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final slot = _slot;

    return AppFormDialog(
      title: 'Buat Reservasi Baru',
      subtitle:
          'Untuk ${widget.customer.name} (${widget.customer.statusLabel})',
      width: 600,
      canSubmit: _slot != null && _capsterId != null && _services.isNotEmpty,
      onSubmit: _submit,
      children: [
        const FieldLabel('Tanggal', required: true),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _days; i++)
              Pill(
                label: i == 0
                    ? 'Hari ini'
                    : DateFormatId.compactDate(_today.add(Duration(days: i))),
                selected: _date == _today.add(Duration(days: i)),
                onTap: () => _pickDate(_today.add(Duration(days: i))),
              ),
          ],
        ),
        const SizedBox(height: 14),
        const FieldLabel('Jam', required: true),
        if (_loading)
          Skeleton(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 8; i++)
                  const SkeletonBox(width: 64, height: 32, radius: 16),
              ],
            ),
          )
        else if (_error != null)
          Text(
            _error!,
            style: AppTextStyle.caption.copyWith(color: AppColor.danger),
          )
        else if (_slots.every((s) => s.freeCapsters.isEmpty))
          Text(
            'Tidak ada jam kosong di tanggal ini.',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _slots)
                if (s.freeCapsters.isNotEmpty)
                  Pill(
                    label: s.time,
                    height: 32,
                    selected: _slot?.time == s.time,
                    onTap: () => setState(() {
                      _slot = s;
                      if (!s.freeCapsters.any((c) => c.id == _capsterId)) {
                        _capsterId = null;
                      }
                    }),
                  ),
            ],
          ),
        if (slot != null) ...[
          const SizedBox(height: 14),
          const FieldLabel('Capster kosong di jam ini', required: true),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in slot.freeCapsters)
                Pill(
                  label: c.name,
                  style: PillStyle.soft,
                  selected: _capsterId == c.id,
                  onTap: () => setState(() => _capsterId = c.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        const FieldLabel('Layanan / Paket', required: true),
        for (final item in _services)
          CartItemTile(
            item: catalog.byId(item.id) ?? item,
            subtitle: item.type.label,
            onRemove: () => setState(() => _services.remove(item)),
          ),
        SizedBox(
          height: 38,
          child: TextButton(
            style: AppButtonStyle.softGold,
            onPressed: _addService,
            child: const Text(
              'Tambah Layanan / Paket',
              style: AppTextStyle.label,
            ),
          ),
        ),
        if (_services.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Total ${PriceFormat.full(_services.fold(0, (sum, s) => sum + s.price))}',
            style: AppTextStyle.bodyBold.copyWith(color: AppColor.gold),
          ),
        ],
      ],
    );
  }
}
