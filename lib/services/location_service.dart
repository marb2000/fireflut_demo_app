import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  LocationData({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) {
        if (kDebugMode) print('Location permission denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (kDebugMode) print('No placemarks found');
        return null;
      }

      final place = placemarks.first;
      if (kDebugMode) {
        print('Location found: ${place.locality}, ${place.country}');
      }

      return LocationData(
        city: place.locality ?? 'Unknown',
        country: place.country ?? 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (kDebugMode) print('Location error: $e');
      return null;
    }
  }
}
