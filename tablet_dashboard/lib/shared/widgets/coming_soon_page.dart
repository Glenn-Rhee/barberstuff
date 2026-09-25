import 'package:flutter/material.dart';

import 'common.dart';
import 'page_header.dart';
import 'store_widgets.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(title: title, subtitle: subtitle, actions: const [ShiftStatusChip()]),
          Expanded(
            child: EmptyState(
              icon: Icons.construction_outlined,
              title: 'Segera hadir',
              message: 'Halaman $title masih menunggu desain.',
            ),
          ),
        ],
      ),
    );
  }
}
