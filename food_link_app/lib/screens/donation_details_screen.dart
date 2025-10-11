import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/donation_model.dart';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/enhanced_animations.dart';
import '../widgets/enhanced_ui_widgets.dart';
import 'map_view_screen.dart';

class DonationDetailsScreen extends StatefulWidget {
  final DonationModel donation;

  const DonationDetailsScreen({
    super.key,
    required this.donation,
  });

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _currentAddress;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLocationData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationData() async {
    try {
      // Get current location to calculate distance
      final locationResult = await LocationService.getCurrentLocationWithStatus();
      if (locationResult['success'] && locationResult['position'] != null) {
        final position = locationResult['position'];
        
        // Calculate distance (using mock coordinates for donation)
        final donationLat = 10.5276 + (widget.donation.id * 0.01);
        final donationLng = 76.2144 + (widget.donation.id * 0.01);
        
        _distanceKm = LocationService.calculateDistance(
          position.latitude,
          position.longitude,
          donationLat,
          donationLng,
        );

        // Get formatted address for donation location
        _currentAddress = await LocationService.getFormattedAddress(
          donationLat,
          donationLng,
        );
      }
    } catch (e) {
      debugPrint('Error loading location data: $e');
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomActions(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      title: Text(
        'Donation Details',
        style: TextStyle(
          color: theme.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.textColor),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: theme.textColor),
          onPressed: () => _shareDetails(),
        ),
        IconButton(
          icon: Icon(Icons.favorite_border, color: theme.textColor),
          onPressed: () => _toggleFavorite(),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeProvider theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(theme),
              const SizedBox(height: 16),
              _buildDetailsCard(theme),
              const SizedBox(height: 16),
              _buildLocationCard(theme),
              const SizedBox(height: 16),
              _buildDonorCard(theme),
              const SizedBox(height: 16),
              _buildStatusCard(theme),
              const SizedBox(height: 100), // Space for bottom actions
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: theme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.donation.foodType,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${widget.donation.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.donation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.donation.status,
                  style: TextStyle(
                    color: _getStatusColor(widget.donation.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (widget.donation.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.donation.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.subtleTextColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            theme,
            Icons.schedule,
            'Expiry Date',
            widget.donation.expiryDate,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            Icons.calendar_today,
            'Created',
            _formatDate(widget.donation.createdAt),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            Icons.category,
            'Category',
            widget.donation.category,
          ),
          if (_distanceKm != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              Icons.location_on,
              'Distance',
              '${_distanceKm!.toStringAsFixed(1)} km away',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeProvider theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.subtleTextColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: theme.subtleTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pickup Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openMap(),
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentAddress ?? widget.donation.pickupAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EnhancedUIWidgets.enhancedButton(
                  text: 'Get Directions',
                  onPressed: () => _getDirections(),
                  icon: Icons.directions,
                  type: ButtonType.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedUIWidgets.enhancedButton(
                  text: 'Call Donor',
                  onPressed: () => _callDonor(),
                  icon: Icons.phone,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donor Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: theme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.donation.donorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verified Donor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (23 donations)',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _viewDonorProfile(),
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.subtleTextColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeProvider theme) {
    return EnhancedUIWidgets.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            theme,
            'Created',
            'Donation was created',
            _formatDate(widget.donation.createdAt),
            true,
          ),
          _buildTimelineItem(
            theme,
            'Verified',
            'Donation verified by NGO',
            widget.donation.status == AppStrings.statusVerified ||
                widget.donation.status == AppStrings.statusAllocated ||
                widget.donation.status == AppStrings.statusDelivered
                ? '2 hours ago'
                : null,
            widget.donation.status == AppStrings.statusVerified ||
                widget.donation.status == AppStrings.statusAllocated ||
                widget.donation.status == AppStrings.statusDelivered,
          ),
          _buildTimelineItem(
            theme,
            'Allocated',
            'Assigned to receiver',
            widget.donation.status == AppStrings.statusAllocated ||
                widget.donation.status == AppStrings.statusDelivered
                ? '1 hour ago'
                : null,
            widget.donation.status == AppStrings.statusAllocated ||
                widget.donation.status == AppStrings.statusDelivered,
          ),
          _buildTimelineItem(
            theme,
            'Delivered',
            'Successfully delivered',
            widget.donation.status == AppStrings.statusDelivered ? '30 min ago' : null,
            widget.donation.status == AppStrings.statusDelivered,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ThemeProvider theme,
    String title,
    String subtitle,
    String? time,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? theme.primaryColor : theme.subtleTextColor,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 12,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: theme.borderColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? theme.textColor : theme.subtleTextColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.subtleTextColor,
                ),
              ),
              if (time != null)
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.subtleTextColor,
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: EnhancedUIWidgets.enhancedButton(
                text: _getActionButtonText(),
                onPressed: () => _performAction(),
                isLoading: _isLoading,
                isEnabled: !_isLoading,
                icon: _getActionButtonIcon(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActionButtonText() {
    switch (widget.donation.status) {
      case AppStrings.statusPending:
        return 'Request This Donation';
      case AppStrings.statusVerified:
        return 'Request This Donation';
      case AppStrings.statusAllocated:
        return 'Contact for Pickup';
      case AppStrings.statusDelivered:
        return 'Mark as Received';
      case AppStrings.statusExpired:
        return 'Donation Expired';
      default:
        return 'Request This Donation';
    }
  }

  IconData _getActionButtonIcon() {
    switch (widget.donation.status) {
      case AppStrings.statusPending:
      case AppStrings.statusVerified:
        return Icons.add_circle_outline;
      case AppStrings.statusAllocated:
        return Icons.phone;
      case AppStrings.statusDelivered:
        return Icons.check_circle;
      case AppStrings.statusExpired:
        return Icons.error;
      default:
        return Icons.add_circle_outline;
    }
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _performAction() async {
    setState(() => _isLoading = true);
    
    try {
      HapticFeedback.mediumImpact();
      
      switch (widget.donation.status) {
        case AppStrings.statusPending:
        case AppStrings.statusVerified:
          await _requestDonation();
          break;
        case AppStrings.statusAllocated:
          await _contactForPickup();
          break;
        case AppStrings.statusDelivered:
          await _markAsReceived();
          break;
        default:
          break;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestDonation() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      EnhancedUIWidgets.showEnhancedSnackbar(
        context: context,
        message: 'Request submitted successfully!',
        type: SnackbarType.success,
      );
    }
  }

  Future<void> _contactForPickup() async {
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Opening contact options...',
      type: SnackbarType.info,
    );
  }

  Future<void> _markAsReceived() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      EnhancedUIWidgets.showEnhancedSnackbar(
        context: context,
        message: 'Marked as received. Thank you!',
        type: SnackbarType.success,
      );
    }
  }

  void _shareDetails() {
    HapticFeedback.lightImpact();
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Sharing donation details...',
      type: SnackbarType.info,
    );
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Added to favorites!',
      type: SnackbarType.success,
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      EnhancedAnimations.createRoute(
        MapViewScreen(
          donations: [widget.donation],
          initialPosition: LatLng(
            10.5276 + (widget.donation.id * 0.01),
            76.2144 + (widget.donation.id * 0.01),
          ),
        ),
        type: AnimationType.slideFromRight,
      ),
    );
  }

  void _getDirections() {
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Opening directions...',
      type: SnackbarType.info,
    );
  }

  void _callDonor() {
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Calling donor...',
      type: SnackbarType.info,
    );
  }

  void _viewDonorProfile() {
    EnhancedUIWidgets.showEnhancedSnackbar(
      context: context,
      message: 'Opening donor profile...',
      type: SnackbarType.info,
    );
  }
}
