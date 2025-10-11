import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../user_state.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import 'enhanced_map_view.dart';
import 'dart:async';

// ========================================
// COMPLETE DONOR DASHBOARD
// ========================================

class CompleteDonorDashboard extends StatefulWidget {
  const CompleteDonorDashboard({super.key});

  @override
  State<CompleteDonorDashboard> createState() => _CompleteDonorDashboardState();
}

class _CompleteDonorDashboardState extends State<CompleteDonorDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DonorHomeTab(),
      const DonorDonationsTab(),
      const EnhancedMapView(),
      const DonorProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.foregroundLight.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'My Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ========================================
// DONOR HOME TAB
// ========================================

class DonorHomeTab extends StatefulWidget {
  const DonorHomeTab({super.key});

  @override
  State<DonorHomeTab> createState() => _DonorHomeTabState();
}

class _DonorHomeTabState extends State<DonorHomeTab> {
  List<DonationModel> _recentDonations = [];
  bool _isLoading = true;
  int _totalDonations = 0;
  int _activeDonations = 0;
  int _completedDonations = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserState>().user;
      if (user != null) {
        final donations = await ApiService.getUserDonations(user.id);
        if (!mounted) return;
        setState(() {
          _recentDonations = donations.take(5).toList();
          _totalDonations = donations.length;
          _activeDonations = donations.where((d) => 
            d.status == AppStrings.statusPending || 
            d.status == AppStrings.statusVerified ||
            d.status == AppStrings.statusAllocated
          ).length;
          _completedDonations = donations.where((d) => 
            d.status == AppStrings.statusDelivered
          ).length;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (!mounted) return;
      // Don't show error to user, just use empty state
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(fontSize: 14)),
            Text(
              user?.name ?? 'Donor',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            _totalDonations.toString(),
                            Icons.volunteer_activism,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Active',
                            _activeDonations.toString(),
                            Icons.pending_actions,
                            AppColors.statusPending,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            _completedDonations.toString(),
                            Icons.check_circle,
                            AppColors.statusDelivered,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Impact',
                            '${_completedDonations * 5} meals',
                            Icons.restaurant,
                            AppColors.statusVerified,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'Create Donation',
                            Icons.add_circle_outline,
                            AppColors.primary,
                            () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'View Map',
                            Icons.map_outlined,
                            AppColors.statusVerified,
                            () => setState(() => _currentIndex = 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Donations
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Donations',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _recentDonations.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: _recentDonations
                                .map((donation) => _buildDonationCard(donation))
                                .toList(),
                          ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Donation'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtleLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fastfood, color: AppColors.primary),
        ),
        title: Text(
          donation.foodType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${donation.quantity} • ${donation.status}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to donation details
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 64,
              color: AppColors.subtleLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No donations yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first donation to help those in need',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subtleLight),
            ),
          ],
        ),
      ),
    );
  }

  int get _currentIndex => 0;
  set _currentIndex(int value) {
    // This is handled by parent widget
  }
}

// ========================================
// DONOR DONATIONS TAB
// ========================================

class DonorDonationsTab extends StatefulWidget {
  const DonorDonationsTab({super.key});

  @override
  State<DonorDonationsTab> createState() => _DonorDonationsTabState();
}

class _DonorDonationsTabState extends State<DonorDonationsTab> {
  List<DonationModel> _donations = [];
  List<DonationModel> _filteredDonations = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserState>().user;
      if (user != null) {
        final donations = await ApiService.getUserDonations(user.id);
        if (!mounted) return;
        setState(() {
          _donations = donations;
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint('Error loading donations: $e');
      if (!mounted) return;
      // Show empty state instead of error
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
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!donation.foodType.toLowerCase().contains(query)) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('My Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
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
                filled: true,
                fillColor: AppColors.cardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                'All',
                AppStrings.statusPending,
                AppStrings.statusVerified,
                AppStrings.statusAllocated,
                AppStrings.statusDelivered,
                AppStrings.statusExpired,
              ].map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: _selectedFilter == status,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = status);
                    _applyFilters();
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selectedFilter == status ? Colors.black : null,
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Donations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDonations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadDonations,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            return _buildDonationCard(_filteredDonations[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(DonationModel donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.foodType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${donation.quantity}',
                      style: TextStyle(color: AppColors.subtleLight),
                    ),
                    Text(
                      donation.pickupAddress,
                      style: TextStyle(color: AppColors.subtleLight, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.subtleLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No donations found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: AppColors.subtleLight),
          ),
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
}

// ========================================
// DONOR PROFILE TAB
// ========================================

class DonorProfileTab extends StatelessWidget {
  const DonorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'D',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Donor',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: AppColors.subtleLight),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Donor',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              'Edit Profile',
              Icons.edit_outlined,
              () => Navigator.pushNamed(context, AppStrings.routeDonorProfile),
            ),
            _buildMenuItem(
              context,
              'My Donations',
              Icons.volunteer_activism_outlined,
              () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
            ),
            _buildMenuItem(
              context,
              'Notifications',
              Icons.notifications_outlined,
              () {},
            ),
            _buildMenuItem(
              context,
              'Settings',
              Icons.settings_outlined,
              () {},
            ),
            _buildMenuItem(
              context,
              'Help & Support',
              Icons.help_outline,
              () {},
            ),
            _buildMenuItem(
              context,
              'About',
              Icons.info_outline,
              () {},
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              'Logout',
              Icons.logout,
              () async {
                await context.read<UserState>().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppStrings.routeLogin);
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.foregroundLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : AppColors.subtleLight,
        ),
        onTap: onTap,
      ),
    );
  }
}
