import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tablet_dashboard/core/services/location/location_lookup.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/app_toast.dart';

const _tiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.barberstuff.dashboard';

// Titik awal peta kalau cabang belum punya koordinat (Jakarta)
const _fallback = LatLng(-6.2, 106.816666);

// Peta pin cabang, [onTap] diisi = ketuk peta untuk pindah pin
class BranchMapView extends StatelessWidget {
  const BranchMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.mapController,
    this.onTap,
    this.height = 300,
  });

  final double? latitude;
  final double? longitude;
  final MapController? mapController;
  final ValueChanged<LatLng>? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lat = latitude, long = longitude;
    final point = lat == null || long == null ? null : LatLng(lat, long);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: point ?? _fallback,
                initialZoom: point == null ? 11 : 16,
                onTap: onTap == null ? null : (_, latLng) => onTap!(latLng),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _tiles,
                  userAgentPackageName: _userAgent,
                ),
                if (point != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          size: 44,
                          color: AppColor.gold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (onTap != null)
              Positioned(
                left: 12,
                top: 12,
                child: _MapChip(
                  label: point == null
                      ? 'Ketuk peta untuk menandai lokasi cabang'
                      : 'Koordinat terpilih, ketuk peta untuk memindah',
                ),
              ),
            // Wajib oleh kebijakan tile OpenStreetMap
            Positioned(
              right: 6,
              bottom: 4,
              child: Text(
                '© OpenStreetMap',
                style: AppTextStyle.caption.copyWith(
                  fontSize: 9,
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

// Pilih titik GPS: ketuk peta, cari alamat, atau lokasi tablet
class BranchMapPicker extends StatefulWidget {
  const BranchMapPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
    this.addressOf,
    this.height = 300,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double latitude, double longitude) onChanged;

  // Alamat yang sedang diketik, untuk tombol "Cari dari Alamat"
  final String Function()? addressOf;
  final double height;

  @override
  State<BranchMapPicker> createState() => _BranchMapPickerState();
}

class _BranchMapPickerState extends State<BranchMapPicker> {
  final _map = MapController();
  final _lookup = LocationLookup();
  bool _busy = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _set(double lat, double long, {bool move = false}) {
    widget.onChanged(lat, long);
    if (move) _map.move(LatLng(lat, long), 16);
  }

  Future<void> _find(Future<(double, double)?> Function() lookup) async {
    setState(() => _busy = true);
    try {
      final found = await lookup();
      if (!mounted) return;
      if (found == null) {
        AppToast.show(
          context,
          'Alamat tidak ditemukan di peta, tandai manual',
          error: true,
        );
        return;
      }
      _set(found.$1, found.$2, move: true);
    } on LocationException catch (e) {
      if (mounted) AppToast.show(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _searchAddress() {
    final address = widget.addressOf?.call().trim() ?? '';
    if (address.isEmpty) {
      AppToast.show(context, 'Isi alamat lengkap dulu', error: true);
      return;
    }
    _find(() => _lookup.search(address));
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.latitude, long = widget.longitude;
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColor.ink,
      side: const BorderSide(color: AppColor.borderStrong),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BranchMapView(
          latitude: lat,
          longitude: long,
          mapController: _map,
          height: widget.height,
          onTap: (point) => _set(point.latitude, point.longitude),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.addressOf != null)
              OutlinedButton.icon(
                onPressed: _busy ? null : _searchAddress,
                style: buttonStyle,
                icon: const Icon(Icons.travel_explore, size: 16),
                label: const Text('Cari dari Alamat'),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _find(_lookup.current),
              style: buttonStyle,
              icon: const Icon(Icons.my_location, size: 16),
              label: const Text('Lokasi Tablet'),
            ),
            if (_busy)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          lat == null || long == null
              ? 'Titik belum dipilih'
              : 'Koordinat: ${lat.toStringAsFixed(6)}, '
                    '${long.toStringAsFixed(6)}',
          style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
        ),
      ],
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 14, color: AppColor.gold),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.label.copyWith(
              fontSize: 11,
              color: AppColor.surface,
            ),
          ),
        ],
      ),
    );
  }
}
