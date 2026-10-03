import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Label di atas input, [required] = tambah tanda * merah
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.label.copyWith(fontSize: 13);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: style,
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: style.copyWith(color: AppColor.danger),
              ),
          ],
        ),
      ),
    );
  }
}
