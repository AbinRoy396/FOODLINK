import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  /// Get current location with better error handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get coordinates from address (Geocoding)
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  /// Get address from coordinates (Reverse Geocoding)
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return null;
  }

  /// Calculate distance between two points (in km)
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  /// Check if location is within radius
  static bool isWithinRadius({
    required double centerLat,
    required double centerLng,
    required double pointLat,
    required double pointLng,
    required double radiusKm,
  }) {
    final distance = calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusKm;
  }

  /// Get nearby donations (filter by distance)
  static List<T> filterByDistance<T>({
    required List<T> items,
    required double userLat,
    required double userLng,
    required double radiusKm,
    required double Function(T) getItemLat,
    required double Function(T) getItemLng,
  }) {
    return items.where((item) {
      return isWithinRadius(
        centerLat: userLat,
        centerLng: userLng,
        pointLat: getItemLat(item),
        pointLng: getItemLng(item),
        radiusKm: radiusKm,
      );
    }).toList();
  }

  /// Get current location with user-friendly error messages
  static Future<Map<String, dynamic>> getCurrentLocationWithStatus() async {
    try {
      debugPrint('🔍 Starting location request...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📍 Location services enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('❌ Location services disabled');
        return {
          'success': false,
          'error': 'Location services are disabled. Please enable location services in your device settings.',
          'position': null,
          'canOpenSettings': true,
        };
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔐 Current permission status: $permission');

      // Handle different permission states
      if (permission == LocationPermission.denied) {
        debugPrint('🔐 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('🔐 Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'error': 'Location permission was denied. Please tap the location button again and allow access.',
            'position': null,
            'canRetry': true,
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permission denied forever');
        return {
          'success': false,
          'error': 'Location permission is permanently denied. Please enable it in app settings.',
          'position': null,
          'canOpenSettings': true,
        };
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        debugPrint('✅ Permission granted, getting position...');
        
        // Get current position with timeout
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        debugPrint('📍 Got position: ${position.latitude}, ${position.longitude}');

        return {
          'success': true,
          'error': null,
          'position': position,
        };
      }

      return {
        'success': false,
        'error': 'Location permission status unknown: $permission',
        'position': null,
      };
      
    } catch (e) {
      debugPrint('❌ Location error: $e');
      return {
        'success': false,
        'error': 'Failed to get location: ${e.toString()}',
        'position': null,
        'canRetry': true,
      };
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Get formatted address with fallback
  static Future<String> getFormattedAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        List<String> addressParts = [];
        
        if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
        if (place.locality?.isNotEmpty == true) addressParts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty == true) addressParts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty == true) addressParts.add(place.country!);
        
        return addressParts.join(', ');
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }
}
