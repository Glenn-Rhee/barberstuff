import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../data/api/barberstuff_api.dart';
import '../../domain/cash_session.dart';

/// The cash session (shift) the till is running on. Payments can only be recorded
/// while a session is open, which is how the backend models it.
class ShiftController extends ChangeNotifier {
  ShiftController(this._api);

  final BarberstuffApi _api;

  CashSession? session;
  bool loading = false;
  bool busy = false;

  /// Only set when loading the session fails; a rejected action reports back to
  /// its caller instead, so the dashboard doesn't keep showing a stale banner.
  String? error;

  bool get isOpen => session != null;
  String? get sessionId => session?.id;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      session = await _api.cashSession();
    } on ApiException catch (e) {
      error = e.message;
      session = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns an error message, or `null` on success.
  Future<String?> openShift(int saldoBegin) => _run(() async {
    await _api.openCashSession(saldoBegin);
    session = await _api.cashSession();
  });

  /// Closes the till. The backend refuses while the store is still inside its
  /// operating hours, and that refusal comes back as [CloseShiftResult.error].
  Future<CloseShiftResult> closeShift(int amountActual) async {
    final id = sessionId;
    if (id == null) return const CloseShiftResult.failed('Tidak ada shift yang terbuka');
    busy = true;
    notifyListeners();
    try {
      final result = await _api.closeCashSession(sessionId: id, amountActual: amountActual);
      session = null;
      return CloseShiftResult.done(difference: result.difference, status: result.status);
    } on ApiException catch (e) {
      return CloseShiftResult.failed(e.message);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> recordSale({
    required int amount,
    required PaymentType paymentType,
    required String title,
    String? bookingId,
  }) => _run(() async {
    await _api.createTransaction(
      sessionId: sessionId!,
      type: TransactionType.income,
      amount: amount,
      paymentType: paymentType,
      title: title,
      bookingId: bookingId,
    );
    session = await _api.cashSession();
  });

  Future<String?> recordCashOut({required int amount, required String title, String? description}) => _run(() async {
    await _api.createTransaction(
      sessionId: sessionId!,
      type: TransactionType.outcome,
      amount: amount,
      title: title,
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

/// Outcome of closing the till: the server's cash summary, or why it refused.
class CloseShiftResult {
  const CloseShiftResult.done({required this.difference, required this.status}) : error = null;

  const CloseShiftResult.failed(this.error) : difference = 0, status = '';

  final int difference;
  final String status;
  final String? error;

  bool get ok => error == null;
}
