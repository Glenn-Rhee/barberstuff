import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/error_retry_view.dart';
import 'package:mobile_barberstuff/shared/widgets/skeleton.dart';

class BookingStepState extends StatelessWidget {
  const BookingStepState({
    super.key,
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.emptyMessage,
    required this.onRetry,
    required this.child,
    this.skeletonCount = 4,
  });

  final bool loading;
  final ApiException? error;
  final bool isEmpty;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget child;

  /// Banyak baris kerangka saat memuat, disesuaikan tiap langkah.
  final int skeletonCount;

  /// onRetry di sini VoidCallback, sedangkan tarik-ulang minta Future.
  Future<void> _retry() async => onRetry();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (loading) {
      // ListView, bukan Column, supaya tidak meluber kalau layarnya pendek.
      return SkeletonGroup(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          itemCount: skeletonCount,
          separatorBuilder: (BuildContext _, int _) =>
              const SizedBox(height: 10),
          itemBuilder: (BuildContext _, int _) =>
              const SkeletonBox(height: 66, radius: 12),
        ),
      );
    }

    final ApiException? failure = error;
    if (failure != null) {
      return ErrorRetryView(message: failure.message(l10n), onRetry: _retry);
    }

    if (isEmpty) {
      return ErrorRetryView(
        message: emptyMessage,
        onRetry: _retry,
        showButton: false,
      );
    }

    // Isi yang sudah tampil pun tetap bisa ditarik untuk muat ulang.
    return RefreshIndicator(
      onRefresh: _retry,
      color: AppColor.goldDeep,
      child: child,
    );
  }
}

class BookingSelectCard extends StatelessWidget {
  const BookingSelectCard({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 12, 12),
    this.tinted = true,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  /// Latar krem saat terpilih. Kartu barber di desain tetap putih.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: selected && tinted
            ? AppColor.goldSoft.withValues(alpha: 0.18)
            : AppColor.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColor.goldDeep : AppColor.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// [check] memakai centang penuh (pilih cabang); selain itu titik radio.
class BookingRadioDot extends StatelessWidget {
  const BookingRadioDot({
    super.key,
    required this.selected,
    this.check = false,
  });

  static const double _size = 22;

  final bool selected;
  final bool check;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected && check ? AppColor.orange : AppColor.surface,
        border: Border.all(
          color: selected ? AppColor.goldDeep : AppColor.border,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: !selected
          ? null
          : check
          ? const Center(
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColor.surface,
              ),
            )
          : Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.goldDeep,
                ),
              ),
            ),
    );
  }
}
