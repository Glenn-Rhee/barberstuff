import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/features/cashier/shift/data/cash_session_api.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_session.dart';
import 'package:tablet_dashboard/features/cashier/shift/domain/entities/cash_transaction.dart';

// Shift kasir yang sedang jalan. Pembayaran hanya bisa dicatat saat shift buka
class ShiftController extends ChangeNotifier {
  ShiftController(this._api);

  final CashSessionApi _api;

  CashSession? session;
  bool loading = false;
  bool busy = false;

  // Error muat shift saja, error aksi dikembalikan ke pemanggil
  String? error;

  // Backend hanya izinkan role cashier untuk kas & transaksi
  bool enabled = true;

  bool get isOpen => session != null;
  String? get sessionId => session?.id;

  // Alasan pembayaran belum bisa diterima
  String get closedMessage => enabled
<<<<<<< HEAD
      ? 'Shift kasir belum dibuka. Buka shift di Dashboard untuk menerima pembayaran.'
=======
      ? 'Buka shift dulu di Dashboard untuk menerima pembayaran.'
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
      : 'Shift dan pembayaran hanya bisa dilakukan akun kasir.';

  void setEnabled(bool value) {
    enabled = value;
    if (!value) session = null;
    notifyListeners();
  }

<<<<<<< HEAD
  // [silent] = muat ulang di belakang layar: data lama tetap tampil tanpa
  // kerangka loading, dan kalau gagal data lama tidak dihapus
=======
  // [silent] = muat ulang diam-diam, kalau gagal data lama tetap
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Future<void> refresh({bool silent = false}) async {
    if (!enabled) return;
    // Jangan timpa data selagi buka / tutup shift atau catat transaksi
    if (silent && (busy || loading)) return;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      session = await _api.cashSession();
      error = null;
    } on ApiException catch (e) {
      if (silent) return;
      error = e.message;
      session = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Balikin pesan error, atau null kalau berhasil
  Future<String?> openShift(int openingBalance) => _run(() async {
    await _api.openCashSession(openingBalance);
    session = await _api.cashSession();
  });

  // Backend menolak tutup kas selama toko masih jam operasional
  Future<CloseShiftResult> closeShift(int amountActual) async {
    final id = sessionId;
    if (id == null) {
      return const CloseShiftResult.failed('Tidak ada shift yang terbuka');
    }
    busy = true;
    notifyListeners();
    try {
      final result = await _api.closeCashSession(
        sessionId: id,
        amountActual: amountActual,
      );
      session = null;
      return CloseShiftResult.done(
        difference: result.difference,
        status: result.status,
      );
    } on ApiException catch (e) {
      return CloseShiftResult.failed(e.message);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

<<<<<<< HEAD
  // Pemasukan selalu terhubung ke booking (aturan backend).
  // [amount] = yang dibayar setelah [discountAmount] (diskon manual kasir)
=======
  // Pemasukan wajib terhubung booking. [amount] = setelah [discountAmount].
  // Server abaikan [title], judul diisi dari nama layanan booking
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
  Future<String?> recordSale({
    required int amount,
    required PaymentType paymentType,
    String? title,
    String? bookingId,
    String? description,
    int discountAmount = 0,
  }) => _run(() async {
    await _api.createTransaction(
      sessionId: sessionId!,
      type: TransactionType.income,
      amount: amount,
      discountAmount: discountAmount,
      paymentType: paymentType,
      title: title,
      bookingId: bookingId,
      description: description,
    );
    session = await _api.cashSession();
  });

  // Keterangan masuk [description]. Backend wajib title untuk pengeluaran,
  // jadi diisi tetap
  Future<String?> recordCashOut({
    required int amount,
    required String description,
  }) => _run(() async {
    await _api.createTransaction(
      sessionId: sessionId!,
      type: TransactionType.outcome,
      amount: amount,
      title: 'Pengeluaran',
      description: description,
    );
    session = await _api.cashSession();
  });

  Future<String?> _run(Future<void> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

// Hasil tutup shift: selisih uang dari server, atau alasan ditolak
class CloseShiftResult {
  const CloseShiftResult.done({required this.difference, required this.status})
    : error = null;

  const CloseShiftResult.failed(this.error) : difference = 0, status = '';

  final int difference;
  final String status;
  final String? error;

  bool get ok => error == null;
}
