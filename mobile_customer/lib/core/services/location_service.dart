import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';

class UserPosition {
  const UserPosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'latitude': latitude,
    'longitude': longitude,
  };

  static UserPosition? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final double? lat = (json['latitude'] as num?)?.toDouble();
    final double? lng = (json['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return UserPosition(latitude: lat, longitude: lng);
  }
}

class LocationService {
  LocationService(this._cache);

  static const String cacheKey = 'last_known_position';

  final AppCache _cache;

  UserPosition? get lastKnown =>
      UserPosition.fromJson(_cache.readJson(cacheKey)?.asMap);

  Future<UserPosition?> current({bool prompt = false}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return lastKnown;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!prompt) return lastKnown;
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return lastKnown;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final UserPosition result = UserPosition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _cache.writeJson(cacheKey, result.toJson());
      return result;
    } on Object catch (error) {
      debugPrint('LocationService gagal: $error');
      return lastKnown;
    }
  }

  static double distanceKm({
    required UserPosition from,
    required double latitude,
    required double longitude,
  }) {
    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          latitude,
          longitude,
        ) /
        1000;
  }
}
