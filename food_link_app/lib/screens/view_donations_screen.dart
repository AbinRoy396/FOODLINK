import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/donation_model.dart';
import '../services/theme_provider.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/enhanced_animations.dart';
import '../widgets/enhanced_ui_widgets.dart';
import 'donation_details_screen.dart';
import 'map_view_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewDonationsScreen extends StatefulWidget {
  final String? userRole;

  const ViewDonationsScreen({
    super.key,
    this.userRole,
  });

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<DonationModel> _donations = [];
  List<DonationModel> _filteredDonations = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    AppStrings.statusPending,
    AppStrings.statusVerified,
    AppStrings.statusAllocated,
    AppStrings.statusDelivered,
    AppStrings.statusExpired,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDonations();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    setState(() => _isLoading = true);
    
    try {
      HapticFeedback.lightImpact();
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock donations
      _donations = List.generate(15, (index) {
        final statuses = [
          AppStrings.statusPending,
          AppStrings.statusVerified,
          AppStrings.statusAllocated,
          AppStrings.statusDelivered,
          AppStrings.statusExpired,
        ];
        
        final foodTypes = [
          'Rice and Curry',
          'Fresh Vegetables',
          'Bread and Pastries',
          'Cooked Meals',
          'Packaged Snacks',
          'Dairy Products',
          'Fruits',
          'Beverages',
        ];
        
        final categories = [
          'Cooked Food',
          'Raw Ingredients',
          'Packaged Food',
          'Fruits & Vegetables',
          'Dairy Products',
          'Beverages',
          'Bakery Items',
        ];
        
        return DonationModel(
          id: index + 1,
          donorId: 1,
          donorName: 'Donor ${index + 1}',
          foodType: foodTypes[index % foodTypes.length],
          category: categories[index % categories.length],
          quantity: '${(index + 1) * 2} servings',
          description: 'Fresh and healthy food ready for pickup',
          expiryDate: '${DateTime.now().add(Duration(days: index % 5 + 1)).day}/${DateTime.now().month}/${DateTime.now().year}',
          pickupAddress: 'Address ${index + 1}, City',
          status: statuses[index % statuses.length],
          createdAt: DateTime.now().subtract(Duration(hours: index)),
        );
      });
      
      _applyFilters();
    } catch (e) {
      if (mounted) {
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Error loading donations: $e',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDonations = _donations.where((donation) {
        // Status filter
        if (_selectedFilter != 'All' && donation.status != _selectedFilter) {
          return false;
        }
        
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return donation.foodType.toLowerCase().contains(query) ||
                 donation.category.toLowerCase().contains(query) ||
                 donation.donorName.toLowerCase().contains(query);
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      title: Text(
        widget.userRole == AppStrings.roleDonor ? 'My Donations' : 'Available Donations',
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
          icon: Icon(Icons.map, color: theme.textColor),
          onPressed: () => _openMapView(),
          tooltip: 'Map View',
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: theme.textColor),
          onPressed: () => _loadDonations(),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBody(ThemeProvider theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildSearchAndFilters(theme),
          Expanded(
            child: _isLoading
                ? EnhancedUIWidgets.enhancedLoading(message: 'Loading donations...')
                : _buildDonationsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          EnhancedUIWidgets.enhancedSearchBar(
            controller: _searchController,
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
            hint: 'Search donations...',
          ),
          const SizedBox(height: 16),
          
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                      _applyFilters();
                      HapticFeedback.selectionClick();
                    },
                    selectedColor: theme.primaryColor.withOpacity(0.2),
                    checkmarkColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primaryColor : theme.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList(ThemeProvider theme) {
    if (_filteredDonations.isEmpty) {
      return _buildEmptyState(theme);
    }

    return EnhancedRefreshIndicator(
      onRefresh: _loadDonations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredDonations.length,
        itemBuilder: (context, index) {
          final donation = _filteredDonations[index];
          
          return EnhancedAnimations.staggeredListItem(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDonationCard(theme, donation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonationCard(ThemeProvider theme, DonationModel donation) {
    return EnhancedUIWidgets.enhancedCard(
      onTap: () => _openDonationDetails(donation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(donation.category),
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.foodType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      donation.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(donation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  donation.status,
                  style: TextStyle(
                    color: _getStatusColor(donation.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.scale,
                size: 16,
                color: theme.subtleTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                donation.quantity,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.subtleTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Expires: ${donation.expiryDate}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.subtleTextColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  donation.pickupAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: theme.subtleTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                'By ${donation.donorName}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(donation.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.subtleTextColor,
                ),
              ),
            ],
          ),
          
          if (widget.userRole != AppStrings.roleDonor) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: EnhancedUIWidgets.enhancedButton(
                text: _getActionButtonText(donation.status),
                onPressed: () => _performQuickAction(donation),
                type: ButtonType.outline,
                icon: _getActionButtonIcon(donation.status),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: theme.subtleTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No donations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your filters'
                : 'Be the first to create a donation!',
            style: TextStyle(
              fontSize: 14,
              color: theme.subtleTextColor,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
            EnhancedUIWidgets.enhancedButton(
              text: 'Clear Filters',
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                });
                _applyFilters();
              },
              type: ButtonType.outline,
              icon: Icons.clear,
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeProvider theme) {
    if (widget.userRole != AppStrings.roleDonor) return const SizedBox.shrink();
    
    return EnhancedAnimations.pulsingFAB(
      onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
      backgroundColor: theme.primaryColor,
      child: const Icon(
        Icons.add,
        color: Colors.black,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cooked Food':
        return Icons.restaurant;
      case 'Raw Ingredients':
        return Icons.grass;
      case 'Packaged Food':
        return Icons.inventory_2;
      case 'Fruits & Vegetables':
        return Icons.eco;
      case 'Dairy Products':
        return Icons.local_drink;
      case 'Beverages':
        return Icons.local_cafe;
      case 'Bakery Items':
        return Icons.cake;
      default:
        return Icons.fastfood;
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

  String _getActionButtonText(String status) {
    switch (status) {
      case AppStrings.statusPending:
      case AppStrings.statusVerified:
        return 'Request';
      case AppStrings.statusAllocated:
        return 'Contact';
      case AppStrings.statusDelivered:
        return 'Completed';
      case AppStrings.statusExpired:
        return 'Expired';
      default:
        return 'View';
    }
  }

  IconData _getActionButtonIcon(String status) {
    switch (status) {
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
        return Icons.visibility;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _openDonationDetails(DonationModel donation) {
    Navigator.push(
      context,
      EnhancedAnimations.createRoute(
        DonationDetailsScreen(donation: donation),
        type: AnimationType.slideFromRight,
      ),
    );
  }

  void _openMapView() {
    Navigator.push(
      context,
      EnhancedAnimations.createRoute(
        MapViewScreen(
          donations: _filteredDonations,
          initialPosition: const LatLng(10.5276, 76.2144),
        ),
        type: AnimationType.slideFromBottom,
      ),
    );
  }

  Future<void> _performQuickAction(DonationModel donation) async {
    HapticFeedback.mediumImpact();
    
    switch (donation.status) {
      case AppStrings.statusPending:
      case AppStrings.statusVerified:
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Request submitted for ${donation.foodType}',
          type: SnackbarType.success,
        );
        break;
      case AppStrings.statusAllocated:
        EnhancedUIWidgets.showEnhancedSnackbar(
          context: context,
          message: 'Opening contact options...',
          type: SnackbarType.info,
        );
        break;
      default:
        _openDonationDetails(donation);
        break;
    }
  }
}
