import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/donation_model.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'donation_detail_screen.dart';

class NearbyDonationsScreen extends StatefulWidget {
  final double radiusKm;

  const NearbyDonationsScreen({
    super.key,
    this.radiusKm = 10.0,
  });

  @override
  State<NearbyDonationsScreen> createState() => _NearbyDonationsScreenState();
}

class _NearbyDonationsScreenState extends State<NearbyDonationsScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<DonationModel> _allDonations = [];
  List<DonationModel> _nearbyDonations = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyDonations();
  }

  Future<void> _loadNearbyDonations() async {
    setState(() => _isLoading = true);

    try {
      // Get current location
      _currentPosition = await LocationService.getCurrentLocation();
      
      if (_currentPosition == null) {
        setState(() {
          _error = 'Unable to get your location. Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      // Get all donations (you'd filter this on backend in production)
      _allDonations = await ApiService.getAllDonations();

      // Filter nearby donations (within radius)
      _nearbyDonations = [];
      for (var donation in _allDonations) {
        final coords = await LocationService.getCoordinatesFromAddress(
          donation.pickupAddress,
        );
        
        if (coords != null) {
          final distance = LocationService.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            coords.latitude,
            coords.longitude,
          );
          
          if (distance <= widget.radiusKm) {
            _nearbyDonations.add(donation);
          }
        }
      }

      // Create markers
      await _createMarkers();
      
      // Create radius circle
      _createRadiusCircle();

      setState(() {
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load donations: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};

    // Add donation markers
    for (var donation in _nearbyDonations) {
      final coords = await LocationService.getCoordinatesFromAddress(
        donation.pickupAddress,
      );

      if (coords != null) {
        markers.add(
          Marker(
            markerId: MarkerId(donation.id.toString()),
            position: coords,
            infoWindow: InfoWindow(
              title: donation.foodType,
              snippet: '${donation.quantity} - Tap for details',
              onTap: () => _navigateToDetail(donation),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(donation.status),
            ),
          ),
        );
      }
    }

    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  void _createRadiusCircle() {
    if (_currentPosition != null) {
      _circles = {
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          radius: widget.radiusKm * 1000, // Convert km to meters
          fillColor: AppColors.primary.withOpacity(0.1),
          strokeColor: AppColors.primary,
          strokeWidth: 2,
        ),
      };
    }
  }

  double _getMarkerColor(String status) {
    switch (status) {
      case 'Pending':
        return BitmapDescriptor.hueOrange;
      case 'Verified':
        return BitmapDescriptor.hueGreen;
      case 'Allocated':
        return BitmapDescriptor.hueBlue;
      case 'Delivered':
        return BitmapDescriptor.hueViolet;
      case 'Expired':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _navigateToDetail(DonationModel donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationDetailScreen(donation: donation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Donations (${widget.radiusKm.toInt()}km)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyDonations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding nearby donations...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNearbyDonations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : const LatLng(37.7749, -122.4194),
                        zoom: 13,
                      ),
                      markers: _markers,
                      circles: _circles,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      onMapCreated: (controller) => _mapController = controller,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_nearbyDonations.length}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Text(
                                    'Nearby',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${widget.radiusKm.toInt()}km',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Text(
                                    'Radius',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
