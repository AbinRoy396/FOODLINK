import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/donation_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import 'dart:async';

class EnhancedMapView extends StatefulWidget {
  const EnhancedMapView({super.key});

  @override
  State<EnhancedMapView> createState() => _EnhancedMapViewState();
}

class _EnhancedMapViewState extends State<EnhancedMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  List<DonationModel> _donations = [];
  List<DonationModel> _filteredDonations = [];
  DonationModel? _selectedDonation;
  Position? _currentPosition;
  
  MapType _currentMapType = MapType.normal;
  bool _isLoading = true;
  bool _showFilters = false;
  String _selectedStatus = 'All';
  double _radiusKm = 10.0;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // Get current location (with timeout)
      _currentPosition = await LocationService.getCurrentLocation()
          .timeout(const Duration(seconds: 5));
      
      // Fetch all donations (with timeout)
      _donations = await ApiService.getAllDonations()
          .timeout(const Duration(seconds: 10));
      _filteredDonations = _donations;
      
      // Create markers
      if (mounted) _createMarkers();
      
    } catch (e) {
      debugPrint('Map initialization error: $e');
      // Use default location if error
      _currentPosition = null;
      _donations = [];
      _filteredDonations = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load donations. Using default view.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    for (var i = 0; i < _filteredDonations.length; i++) {
      final donation = _filteredDonations[i];
      
      // Generate coordinates (replace with actual lat/lng from donation)
      final lat = (_currentPosition?.latitude ?? 10.5276) + (i * 0.01);
      final lng = (_currentPosition?.longitude ?? 76.2144) + (i * 0.01);

      _markers.add(
        Marker(
          markerId: MarkerId(donation.id.toString()),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(donation.status)),
          infoWindow: InfoWindow(
            title: donation.foodType,
            snippet: '${donation.quantity} • ${donation.status}',
          ),
          onTap: () => _onMarkerTapped(donation),
        ),
      );
    }
    
    // Add radius circle around current location
    if (_currentPosition != null) {
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          radius: _radiusKm * 1000, // Convert km to meters
          fillColor: AppColors.primary.withValues(alpha: 0.1),
          strokeColor: AppColors.primary.withValues(alpha: 0.3),
          strokeWidth: 2,
        ),
      );
    }
    
    setState(() {});
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
    setState(() => _selectedDonation = donation);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_markers.isNotEmpty) {
      _fitMarkersInView();
    }
  }

  void _fitMarkersInView() {
    if (_markers.isEmpty || _mapController == null) return;

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

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        100,
      ),
    );
  }

  void _goToMyLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14,
        ),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.hybrid
              : MapType.normal;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredDonations = _donations.where((donation) {
        // Status filter
        if (_selectedStatus != 'All' && donation.status != _selectedStatus) {
          return false;
        }
        
        // Search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!donation.foodType.toLowerCase().contains(query) &&
              !donation.pickupAddress.toLowerCase().contains(query)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      _createMarkers();
      _showFilters = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = 'All';
      _radiusKm = 10.0;
      _searchController.clear();
      _filteredDonations = _donations;
      _createMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Map'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToMyLocation,
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _toggleMapType,
            tooltip: 'Change Map Type',
          ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(10.5276, 76.2144), // Thrissur, Kerala
                    zoom: 12,
                  ),
                  markers: _markers,
                  circles: _circles,
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Search Bar
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildSearchBar(),
                ),

                // Filter Panel
                if (_showFilters)
                  Positioned(
                    top: 80,
                    left: 16,
                    right: 16,
                    child: _buildFilterPanel(),
                  ),

                // Legend
                Positioned(
                  top: _showFilters ? 380 : 80,
                  right: 16,
                  child: _buildLegend(),
                ),

                // Stats Card
                Positioned(
                  top: _showFilters ? 380 : 80,
                  left: 16,
                  child: _buildStatsCard(),
                ),

                // Selected Donation Card
                if (_selectedDonation != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildDonationCard(_selectedDonation!),
                  ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search donations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status Filter
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'All',
                AppStrings.statusPending,
                AppStrings.statusVerified,
                AppStrings.statusAllocated,
              ].map((status) => ChoiceChip(
                label: Text(status),
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  setState(() => _selectedStatus = status);
                  _applyFilters();
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedStatus == status ? Colors.black : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Radius Filter
            Text('Search Radius: ${_radiusKm.toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _radiusKm,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              label: '${_radiusKm.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() => _radiusKm = value);
                _createMarkers();
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
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
              'Stats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${_filteredDonations.length}',
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              'Nearby: ${_markers.length}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    return Card(
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Quantity: ${donation.quantity}'),
                      Text('Pickup: ${donation.pickupAddress}'),
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
                  onPressed: () => setState(() => _selectedDonation = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to details
                      Navigator.pushNamed(
                        context,
                        '/donation-detail',
                        arguments: donation,
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Get directions
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening directions...')),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
}
