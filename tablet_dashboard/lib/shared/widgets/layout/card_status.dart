import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

class CardStatus extends StatelessWidget {
  const CardStatus({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
            child: Image.asset(icon, color: color, height: 25),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body.copyWith(
                    color: AppColor.inkSoft,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyle.h1.copyWith(fontSize: 32, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
