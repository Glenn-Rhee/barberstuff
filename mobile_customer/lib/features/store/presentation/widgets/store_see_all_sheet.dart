import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// Daftar lengkap di balik "Lihat Semua" pada detail cabang. Tinggi sheet
/// mengikuti isinya, paling tinggi 85% layar lalu isinya bisa digulir.
Future<void> showStoreSeeAllSheet(
  BuildContext context, {
  required String title,
  required String emptyMessage,
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _StoreSeeAllSheet(
      title: title,
      emptyMessage: emptyMessage,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    ),
  );
}

class _StoreSeeAllSheet extends StatelessWidget {
  const _StoreSeeAllSheet({
    required this.title,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
  });

  final String title;
  final String emptyMessage;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                title,
                style: AppTextStyle.titleLarge.copyWith(fontSize: 18),
              ),
            ),
            Flexible(
              child: itemCount == 0
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColor.inkFaint,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: itemCount,
                      separatorBuilder: (BuildContext _, int _) =>
                          const SizedBox(height: 10),
                      itemBuilder: itemBuilder,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
