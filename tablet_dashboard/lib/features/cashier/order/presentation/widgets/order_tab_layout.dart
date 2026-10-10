import 'package:flutter/material.dart';
import 'package:tablet_dashboard/features/cashier/order/presentation/widgets/order_tabs.dart';

// Layout Kasir: tab + [children] di kiri, [panel] di kanan
class OrderTabLayout extends StatelessWidget {
  const OrderTabLayout({
    super.key,
    required this.children,
    required this.panel,
    this.showTabs = true,
  });

  static const double _panelWidth = 336;

  final List<Widget> children;
  final Widget panel;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTabs) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: OrderTabs(),
                ),
                const SizedBox(height: 16),
              ],
              ...children,
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(width: _panelWidth, child: panel),
      ],
    );
  }
}
