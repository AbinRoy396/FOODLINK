import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../user_state.dart';
import '../widgets/offline_indicator.dart';
import '../models/donation_model.dart';
import 'map_view_screen.dart';
import 'simple_map_screen.dart';
import 'openstreet_map_screen.dart';
import 'package:latlong2/latlong.dart' as latlong;

// ========================================
// NGO DASHBOARD WITH TAB NAVIGATION
// ========================================

class ImprovedNGODashboard extends StatefulWidget {
  const ImprovedNGODashboard({super.key});

  @override
  State<ImprovedNGODashboard> createState() => _ImprovedNGODashboardState();
}

class _ImprovedNGODashboardState extends State<ImprovedNGODashboard> {
  int _currentIndex = 0;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const NGOHomeTab(),
      const NGODonationsTab(),
      const NGORequestsTab(),
      const NGOMapTab(),
      const NGOProfileTab(),
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
        selectedFontSize: 11,
        unselectedFontSize: 10,
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
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Requests',
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

// NGO HOME TAB
class NGOHomeTab extends StatelessWidget {
  const NGOHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fgColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.9)),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: fgColor.withValues(alpha: 0.7)),
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
                      'Welcome, ${user?.name ?? "NGO"}! 👋',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: fgColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage donations and help those in need',
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
                  icon: Icons.check_circle_outline,
                  label: 'Verify',
                  color: Colors.green,
                  onTap: () {
                    final dashboardState = context.findAncestorStateOfType<_ImprovedNGODashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 1);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Requests',
                  color: Colors.blue,
                  onTap: () {
                    final dashboardState = context.findAncestorStateOfType<_ImprovedNGODashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 2);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.map,
                  label: 'Map View',
                  color: Colors.orange,
                  onTap: () {
                    final dashboardState = context.findAncestorStateOfType<_ImprovedNGODashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 3);
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
            label: 'Total Verified',
            value: '0',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            label: 'Helped',
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
          'Manage Operations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Verify Donations',
          description: 'Review and verify pending donations from donors',
          imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=400',
          buttonText: 'Start Verifying',
          onPressed: () {
            final dashboardState = context.findAncestorStateOfType<_ImprovedNGODashboardState>();
            dashboardState?.setState(() => dashboardState._currentIndex = 1);
          },
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Allocate Resources',
          description: 'Match donations with receiver requests efficiently',
          imageUrl: 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400',
          buttonText: 'Manage Requests',
          onPressed: () {
            final dashboardState = context.findAncestorStateOfType<_ImprovedNGODashboardState>();
            dashboardState?.setState(() => dashboardState._currentIndex = 2);
          },
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

// NGO DONATIONS TAB
class NGODonationsTab extends StatefulWidget {
  const NGODonationsTab({super.key});

  @override
  State<NGODonationsTab> createState() => _NGODonationsTabState();
}

class _NGODonationsTabState extends State<NGODonationsTab> {
  List<DonationModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);
    try {
      donations = await ApiService.getAllDonations();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Donations'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDonations)]),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : donations.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.volunteer_activism_outlined, size: 80, color: AppColors.subtleLight), const SizedBox(height: 16), const Text('No donations yet')]))
                    : RefreshIndicator(
                        onRefresh: _loadDonations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donations.length,
                          itemBuilder: (context, index) {
                            final donation = donations[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.fastfood, color: AppColors.primary)),
                                title: Text(donation.foodType, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Quantity: ${donation.quantity}\nStatus: ${donation.status}'),
                                isThreeLine: true,
                                trailing: Icon(donation.status == 'Pending' ? Icons.pending : Icons.check_circle, color: donation.status == 'Pending' ? Colors.orange : Colors.green),
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

// NGO REQUESTS TAB
class NGORequestsTab extends StatelessWidget {
  const NGORequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Requests')),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.subtleLight),
                  const SizedBox(height: 16),
                  const Text('No requests yet'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// NGO MAP TAB
class NGOMapTab extends StatefulWidget {
  const NGOMapTab({super.key});

  @override
  State<NGOMapTab> createState() => _NGOMapTabState();
}

class _NGOMapTabState extends State<NGOMapTab> {
  List<DonationModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);
    try {
      donations = await ApiService.getAllDonations();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donations Map'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDonations)]),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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

// NGO PROFILE TAB
class NGOProfileTab extends StatelessWidget {
  const NGOProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(radius: 50, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(user?.name[0].toUpperCase() ?? 'N', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary))),
            const SizedBox(height: 16),
            Text(user?.name ?? 'NGO', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.subtleLight)),
            const SizedBox(height: 8),
            Chip(label: Text(user?.role ?? 'NGO'), backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.person), title: const Text('Edit Profile'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, AppStrings.routeNGOProfile)),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    title: const Text('Theme'),
                    trailing: Switch(value: isDark, onChanged: (value) => context.read<ThemeProvider>().toggleTheme(), activeColor: AppColors.primary),
                  ),
                ],
              ),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
