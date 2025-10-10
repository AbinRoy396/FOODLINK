import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/donation_model.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';

class EnhancedMapScreen extends StatefulWidget {
  final List<DonationModel> donations;
  final String? highlightDonationId;

  const EnhancedMapScreen({
    super.key,
    required this.donations,
    this.highlightDonationId,
  });

  @override
  State<EnhancedMapScreen> createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Get current location
    _currentPosition = await LocationService.getCurrentLocation();
    
    // Create markers for donations
    await _createDonationMarkers();
    
    setState(() => _isLoading = false);
    
    // Move camera to current location or first donation
    if (_mapController != null) {
      if (_currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          ),
        );
      } else if (widget.donations.isNotEmpty) {
        // Use first donation's location (if available)
        final firstDonation = widget.donations.first;
        if (firstDonation.pickupAddress.isNotEmpty) {
          final coords = await LocationService.getCoordinatesFromAddress(
            firstDonation.pickupAddress,
          );
          if (coords != null && _mapController != null) {
            _mapController!.animateCamera(CameraUpdate.newLatLng(coords));
          }
        }
      }
    }
  }

  Future<void> _createDonationMarkers() async {
    final markers = <Marker>{};

    for (var donation in widget.donations) {
      // Get coordinates from address
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
              snippet: '${donation.quantity} - ${donation.status}',
              onTap: () => _showDonationDetails(donation),
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
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    setState(() => _markers = markers);
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

  void _showDonationDetails(DonationModel donation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fastfood, size: 40, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.foodType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        donation.status,
                        style: TextStyle(
                          color: AppColors.subtleLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.scale, label: 'Quantity', value: donation.quantity),
            _InfoRow(icon: Icons.location_on, label: 'Pickup', value: donation.pickupAddress),
            _InfoRow(icon: Icons.access_time, label: 'Expires', value: donation.expiryTime),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to donation detail screen
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('View Full Details'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Map'),
        actions: [
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ),
                );
              },
              tooltip: 'Go to my location',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _initializeMap();
            },
            tooltip: 'Refresh markers',
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
                  Text('Loading map...'),
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              mapType: MapType.normal,
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'legend',
            onPressed: _showLegend,
            child: const Icon(Icons.info_outline),
            tooltip: 'Show Legend',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'location',
            onPressed: () async {
              final position = await LocationService.getCurrentLocation();
              if (position != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 15,
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.my_location),
            tooltip: 'Center on my location',
          ),
        ],
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendItem(color: Colors.orange, label: 'Pending'),
            _LegendItem(color: Colors.green, label: 'Verified'),
            _LegendItem(color: Colors.blue, label: 'Allocated'),
            _LegendItem(color: Colors.purple, label: 'Delivered'),
            _LegendItem(color: Colors.red, label: 'Expired'),
            _LegendItem(color: Colors.cyan, label: 'Your Location'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.subtleLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subtleLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
