import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/animations.dart';
import '../user_state.dart';
import '../widgets/offline_indicator.dart';
import '../models/donation_model.dart';
import 'map_view_screen.dart';
import 'simple_map_screen.dart';
import 'openstreet_map_screen.dart';
import 'package:latlong2/latlong.dart' as latlong;

// ========================================
// DONOR DASHBOARD WITH TAB NAVIGATION
// ========================================

class ImprovedDonorDashboard extends StatefulWidget {
  const ImprovedDonorDashboard({super.key});

  @override
  State<ImprovedDonorDashboard> createState() => _ImprovedDonorDashboardState();
}

class _ImprovedDonorDashboardState extends State<ImprovedDonorDashboard> {
  int _currentIndex = 0;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DonorHomeTab(),
      const DonorDonationsTab(),
      const DonorMapTab(),
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
        backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.95),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.foregroundLight.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
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
            label: 'Donations',
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

class DonorHomeTab extends StatelessWidget {
  const DonorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Please log in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppStrings.routeLogin),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fgColor.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: fgColor.withValues(alpha: 0.7),
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: fgColor.withValues(alpha: 0.7)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshed!')),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.name}! 👋',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: fgColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make a difference today by donating food',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: fgColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildStatsCards(context, fgColor),
                    const SizedBox(height: 24),
                    _buildActionCards(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Donate',
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.list_alt,
                  label: 'My Donations',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.map,
                  label: 'Map View',
                  color: Colors.green,
                  onTap: () {
                    // Switch to map tab
                    final dashboardState = context.findAncestorStateOfType<_ImprovedDonorDashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 2);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Color fgColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.volunteer_activism,
            label: 'Total Donations',
            value: '0',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            label: 'People Helped',
            value: '0',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.subtleLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Started',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Create Donation',
          description: 'Donate surplus food to those in need',
          imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
          buttonText: 'Start Donating',
          onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Track Your Impact',
          description: 'See how your donations are making a difference',
          imageUrl: 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400',
          buttonText: 'View Stats',
          onPressed: () => Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required String imageUrl,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.image, size: 64, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(buttonText),
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

// ========================================
// DONOR DONATIONS TAB
// ========================================

class DonorDonationsTab extends StatefulWidget {
  const DonorDonationsTab({super.key});

  @override
  State<DonorDonationsTab> createState() => _DonorDonationsTabState();
}

class _DonorDonationsTabState extends State<DonorDonationsTab> {
  List<dynamic> donations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);
    try {
      final user = context.read<UserState>().user;
      if (user != null) {
        donations = await ApiService.getUserDonations(user.id);
        error = null;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          'My Donations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fgColor.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
            tooltip: 'Create Donation',
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDonations,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Error: $error'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDonations,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : donations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.volunteer_activism_outlined,
                                    size: 80,
                                    color: AppColors.subtleLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No donations yet',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start making a difference today!',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Donation'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: donations.length,
                              itemBuilder: (context, index) {
                                final donation = donations[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(Icons.fastfood, color: AppColors.primary),
                                    ),
                                    title: Text(
                                      donation['foodType'] ?? 'Food',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text('Quantity: ${donation['quantity']}'),
                                        Text('Status: ${donation['status']}'),
                                      ],
                                    ),
                                    trailing: Icon(
                                      donation['status'] == 'Pending'
                                          ? Icons.pending
                                          : Icons.check_circle,
                                      color: donation['status'] == 'Pending'
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// DONOR MAP TAB
// ========================================

class DonorMapTab extends StatefulWidget {
  const DonorMapTab({super.key});

  @override
  State<DonorMapTab> createState() => _DonorMapTabState();
}

class _DonorMapTabState extends State<DonorMapTab> {
  List<DonationModel> donations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);
    try {
      donations = await ApiService.getAllDonations();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text('Donations Map'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDonations)]),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error loading map: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDonations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : OpenStreetMapScreen(
                        donations: donations,
                        initialPosition: latlong.LatLng(10.5276, 76.2144), // Thrissur, Kerala
                      ),
          ),
        ],
      ),
    );
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
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fgColor.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.subtleLight,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileSection(
              context,
              title: 'Account',
              items: [
                _buildProfileItem(
                  context,
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () => Navigator.pushNamed(context, AppStrings.routeDonorProfile),
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.location_on,
                  title: 'Address',
                  subtitle: user.address ?? 'Not set',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSection(
              context,
              title: 'Preferences',
              items: [
                _buildProfileItem(
                  context,
                  icon: isDark ? Icons.light_mode : Icons.dark_mode,
                  title: 'Theme',
                  subtitle: isDark ? 'Dark' : 'Light',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                  onTap: () => context.read<ThemeProvider>().toggleTheme(),
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Enabled',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSection(
              context,
              title: 'Support',
              items: [
                _buildProfileItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<UserState>().logout();
                  Navigator.pushReplacementNamed(context, AppStrings.routeLogin);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
