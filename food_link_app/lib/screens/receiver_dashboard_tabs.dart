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
// RECEIVER DASHBOARD WITH TAB NAVIGATION
// ========================================

class ImprovedReceiverDashboard extends StatefulWidget {
  const ImprovedReceiverDashboard({super.key});

  @override
  State<ImprovedReceiverDashboard> createState() => _ImprovedReceiverDashboardState();
}

class _ImprovedReceiverDashboardState extends State<ImprovedReceiverDashboard> {
  int _currentIndex = 0;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ReceiverHomeTab(),
      const ReceiverDonationsTab(),
      const ReceiverRequestsTab(),
      const ReceiverMapTab(),
      const ReceiverProfileTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), activeIcon: Icon(Icons.card_giftcard), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// RECEIVER HOME TAB
class ReceiverHomeTab extends StatelessWidget {
  const ReceiverHomeTab({super.key});

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
        title: Text(AppStrings.appName, style: TextStyle(fontWeight: FontWeight.bold, color: fgColor)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: fgColor.withValues(alpha: 0.7)),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${user?.name ?? "User"}! 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.9))),
                  const SizedBox(height: 8),
                  Text('Find food donations near you', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: fgColor.withValues(alpha: 0.6))),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, Icons.card_giftcard, 'Available', '0', Colors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, Icons.list_alt, 'My Requests', '0', Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActionCard(context, 'Browse Donations', 'Find available food donations', Icons.search, () {
                    final dashboardState = context.findAncestorStateOfType<_ImprovedReceiverDashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 1);
                  }),
                  const SizedBox(height: 16),
                  _buildActionCard(context, 'Create Request', 'Request specific food items', Icons.add_circle, () {
                    Navigator.pushNamed(context, AppStrings.routeCreateRequest);
                  }),
                  const SizedBox(height: 16),
                  _buildActionCard(context, 'View on Map', 'See donations near you', Icons.map, () {
                    final dashboardState = context.findAncestorStateOfType<_ImprovedReceiverDashboardState>();
                    dashboardState?.setState(() => dashboardState._currentIndex = 3);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// RECEIVER DONATIONS TAB
class ReceiverDonationsTab extends StatefulWidget {
  const ReceiverDonationsTab({super.key});

  @override
  State<ReceiverDonationsTab> createState() => _ReceiverDonationsTabState();
}

class _ReceiverDonationsTabState extends State<ReceiverDonationsTab> {
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
      appBar: AppBar(title: const Text('Available Donations'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDonations)]),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : donations.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.card_giftcard_outlined, size: 80, color: AppColors.subtleLight), const SizedBox(height: 16), const Text('No donations available')]))
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
                                subtitle: Text('Quantity: ${donation.quantity}\nLocation: ${donation.pickupAddress}'),
                                isThreeLine: true,
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!')));
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                                  child: const Text('Request'),
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

// RECEIVER REQUESTS TAB
class ReceiverRequestsTab extends StatelessWidget {
  const ReceiverRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateRequest),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_outlined, size: 80, color: AppColors.subtleLight),
                  const SizedBox(height: 16),
                  const Text('No requests yet'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateRequest),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Request'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// RECEIVER MAP TAB
class ReceiverMapTab extends StatefulWidget {
  const ReceiverMapTab({super.key});

  @override
  State<ReceiverMapTab> createState() => _ReceiverMapTabState();
}

class _ReceiverMapTabState extends State<ReceiverMapTab> {
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
      appBar: AppBar(title: const Text('Donations Near Me'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDonations)]),
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

// RECEIVER PROFILE TAB
class ReceiverProfileTab extends StatelessWidget {
  const ReceiverProfileTab({super.key});

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
            CircleAvatar(radius: 50, backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(user?.name[0].toUpperCase() ?? 'R', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary))),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Receiver', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.subtleLight)),
            const SizedBox(height: 8),
            Chip(label: Text(user?.role ?? 'Receiver'), backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.person), title: const Text('Edit Profile'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pushNamed(context, AppStrings.routeReceiverProfile)),
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
