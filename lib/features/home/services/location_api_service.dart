// lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Minta permission + ambil nama kota user
  Future<String> getCurrentCity() async {
    try {
      // Cek apakah location service aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Lokasi mati';

      // Cek & minta permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'Izin ditolak';
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Izin ditolak permanen';
      }

      // Ambil posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode ke nama kota
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return 'Lokasi tidak diketahui';

      final place = placemarks.first;

      // Prioritas: subLocality → locality → subAdministrativeArea
      final city = place.subLocality?.isNotEmpty == true
          ? place.subLocality!
          : place.locality?.isNotEmpty == true
              ? place.locality!
              : place.subAdministrativeArea ?? 'Lokasi tidak diketahui';

      return city;
    } catch (e) {
      return 'Lokasi tidak diketahui';
    }
  }
}