import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Peta OpenStreetMap: penanda toko, posisi pengguna, dan garis penghubung.
/// Navigasi belok-per-belok diserahkan ke aplikasi peta lewat [onTap].
class StoreMapPreview extends StatelessWidget {
  const StoreMapPreview({
    super.key,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.userPosition,
    required this.onTap,
  });

  static const double _height = 180;
  static const double _radius = 12;

  /// Lebih jauh dari ini, peta tidak ditarik mundur untuk memuat posisi
  /// pengguna. Kalau dipaksa, yang tampil peta dunia dan tokonya jadi titik
  /// kecil (kejadian di emulator yang lokasinya default di California).
  static const double _maxFitKm = 50;
  static const String _tiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  final double storeLatitude;
  final double storeLongitude;
  final UserPosition? userPosition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LatLng store = LatLng(storeLatitude, storeLongitude);
    final UserPosition? from = userPosition;

    final double? km = from == null
        ? null
        : LocationService.distanceKm(
            from: from,
            latitude: storeLatitude,
            longitude: storeLongitude,
          );

    // Titik pengguna dan garisnya cuma digambar kalau masih wajar dekat.
    // Jaraknya tetap ditampilkan di chip walau sangat jauh.
    final LatLng? user = from != null && km != null && km <= _maxFitKm
        ? LatLng(from.latitude, from.longitude)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        height: _height,
        child: Stack(
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                initialCenter: store,
                initialZoom: 14,
                initialCameraFit: user == null
                    ? null
                    : CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(<LatLng>[store, user]),
                        padding: const EdgeInsets.all(40),
                      ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate: _tiles,
                  userAgentPackageName: 'com.barberstuff.mobile',
                ),
                if (user != null)
                  PolylineLayer<Object>(
                    polylines: <Polyline<Object>>[
                      Polyline<Object>(
                        points: <LatLng>[user, store],
                        strokeWidth: 3,
                        color: AppColor.goldDeep,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: <Marker>[
                    if (user != null)
                      Marker(
                        point: user,
                        width: 18,
                        height: 18,
                        child: const _UserDot(),
                      ),
                    Marker(
                      point: store,
                      width: 34,
                      height: 34,
                      child: const _StorePin(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
            if (km != null)
              Positioned(
                left: 10,
                bottom: 10,
                child: _DistanceChip(
                  label: l10n.homeNearbyDistance(
                    km < 10 ? km.toStringAsFixed(1) : km.round().toString(),
                  ),
                ),
              ),
            // Wajib oleh kebijakan tile OpenStreetMap.
            Positioned(
              right: 6,
              bottom: 4,
              child: Text(
                '© OpenStreetMap',
                style: AppTextStyle.labelSmall.copyWith(
                  fontSize: 8,
                  color: AppColor.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePin extends StatelessWidget {
  const _StorePin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.goldDeep,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(7),
      child: Image.asset(
        AppAssets.locationIcon,
        fit: BoxFit.contain,
        color: AppColor.surface,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.customKeyProfileInfo2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.surface, width: 3),
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelSmall.copyWith(
          color: AppColor.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
