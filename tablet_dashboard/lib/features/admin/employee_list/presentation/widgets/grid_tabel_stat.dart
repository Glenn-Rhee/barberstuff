import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/shared/widgets/layout/card_status.dart';

class GridTabelStat extends StatefulWidget {
  const GridTabelStat({super.key});

  @override
  State<GridTabelStat> createState() => _GridTabelStatState();
}

class _GridTabelStatState extends State<GridTabelStat> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CardStatus(
            icon: AppAsset.employeesIcon,
            label: "Total Karyawan",
            value: '0',
            color: AppColor.iconPersonal,
            softColor: AppColor.warningSoft,
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: CardStatus(
            icon: AppAsset.employeeActiveIcon,
            label: "Aktif",
            value: '0',
            color: AppColor.success,
            softColor: AppColor.boxActive,
          ),
        ),
        SizedBox(width: 18),

        Expanded(
          child: CardStatus(
            icon: AppAsset.employeeInactiveIcon,
            label: "Tidak Aktif",
            value: '0',
            color: AppColor.iconInActive,
            softColor: AppColor.boxInActive,
          ),
        ),
        SizedBox(width: 18),

        Expanded(
          child: CardStatus(
            icon: AppAsset.buildingIcon,
            label: "Jumlah Cabang",
            value: '0',
            color: AppColor.iconBuilding,
            softColor: AppColor.boxBuilding,
          ),
        ),
      ],
    );
  }
}
