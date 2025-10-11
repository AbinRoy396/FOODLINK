import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/donation_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import 'dart:async';

class MapViewScreen extends StatefulWidget {
  final List<DonationModel>? donations;
  final LatLng? initialPosition;

  const MapViewScreen({
    super.key,
    this.donations,
    this.initialPosition,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  DonationModel? _selectedDonation;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeMarkers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMarkers() {
    if (widget.donations == null) return;

    for (var i = 0; i < widget.donations!.length; i++) {
      final donation = widget.donations![i];
      // Generate random coordinates for demo (replace with actual coordinates)
      final lat = 10.5276 + (i * 0.01);
      final lng = 76.2144 + (i * 0.01);

      _markers.add(
        Marker(
          markerId: MarkerId(donation.id.toString()),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(donation.status),
          ),
          infoWindow: InfoWindow(
            title: donation.foodType,
            snippet: '${donation.quantity} - ${donation.status}',
          ),
          onTap: () => _onMarkerTapped(donation),
        ),
      );
    }
  }

  double _getMarkerColor(String status) {
    switch (status) {
      case AppStrings.statusVerified:
        return BitmapDescriptor.hueGreen;
      case AppStrings.statusPending:
        return BitmapDescriptor.hueOrange;
      case AppStrings.statusAllocated:
        return BitmapDescriptor.hueViolet;
      case AppStrings.statusDelivered:
        return BitmapDescriptor.hueBlue;
      case AppStrings.statusExpired:
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMarkerTapped(DonationModel donation) {
    setState(() {
      _selectedDonation = donation;
    });
    _animationController.forward();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_markers.isNotEmpty) {
      _fitMarkersInView();
    }
  }

  void _fitMarkersInView() {
    if (_markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (var marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Locations'),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_mapController != null && widget.initialPosition != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.initialPosition!, 14),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              // Toggle map type
              setState(() {
                // Implement map type toggle
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition ?? const LatLng(10.5276, 76.2144), // Thrissur, Kerala
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            style: isDark ? _darkMapStyle : null,
          ),
          
          // Selected donation card
          if (_selectedDonation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: _buildDonationCard(_selectedDonation!),
              ),
            ),

          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    return Hero(
      tag: 'donation_${donation.id}',
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.foodType,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${donation.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(donation.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      donation.status,
                      style: TextStyle(
                        color: _getStatusColor(donation.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _animationController.reverse();
                      setState(() {
                        _selectedDonation = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Close the card and show details in a dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(donation.foodType),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity: ${donation.quantity}'),
                                const SizedBox(height: 8),
                                Text('Status: ${donation.status}'),
                                const SizedBox(height: 8),
                                Text('Pickup: ${donation.pickupAddress}'),
                                if (donation.expiryTime != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Expires: ${donation.expiryTime}'),
                                ],
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
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Legend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildLegendItem('Verified', AppColors.statusVerified),
            _buildLegendItem('Pending', AppColors.statusPending),
            _buildLegendItem('Allocated', AppColors.statusAllocated),
            _buildLegendItem('Delivered', AppColors.statusDelivered),
            _buildLegendItem('Expired', AppColors.statusExpired),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppStrings.statusPending:
        return AppColors.statusPending;
      case AppStrings.statusVerified:
        return AppColors.statusVerified;
      case AppStrings.statusAllocated:
        return AppColors.statusAllocated;
      case AppStrings.statusDelivered:
        return AppColors.statusDelivered;
      case AppStrings.statusExpired:
        return AppColors.statusExpired;
      default:
        return AppColors.foregroundLight;
    }
  }

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    }
  ]
  ''';
}
