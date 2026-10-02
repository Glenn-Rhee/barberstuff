import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/deeplink/store_link.dart';
import 'package:mobile_barberstuff/core/storage/app_session.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/store/presentation/pages/store_detail_page.dart';
import 'package:provider/provider.dart';

/// Pintu masuk dari tautan bagikan saat aplikasi sudah terbuka.
/// Sudah login: langsung detail cabang. Belum login: tautannya disimpan,
/// halaman ini ditutup, dan detail cabang dibuka setelah user sampai
/// di beranda. Detail cabang butuh token, jadi tidak bisa dibuka duluan.
class SharedStoreEntry extends StatefulWidget {
  const SharedStoreEntry({super.key, required this.storeId});

  final String storeId;

  @override
  State<SharedStoreEntry> createState() => _SharedStoreEntryState();
}

class _SharedStoreEntryState extends State<SharedStoreEntry> {
  late final bool _signedIn = context.read<AppSession>().hasValidSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || _signedIn) return;

      StoreLink.hold(widget.storeId);
      Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return StoreDetailPage(args: StoreDetailArgs(storeId: widget.storeId));
    }

    return const Scaffold(backgroundColor: AppColor.surface);
  }
}
