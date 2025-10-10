import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/state_preservation_mixin.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- View Donations Screen ---
class ViewDonationsScreen extends StatefulWidget {
  const ViewDonationsScreen({super.key});

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> donations = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);

    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        donations = await ApiService.getAllDonations();
        error = null;
      } else {
        error = 'User not logged in';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Available Donations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.subtleLight),
                    const SizedBox(height: 16),
                    Text(error!, style: const TextStyle(color: AppColors.subtleLight)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadDonations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : donations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No donations available', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final donation = donations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        donation['foodType'] ?? 'Unknown Food',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foregroundLight,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Available',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quantity: ${donation['quantity'] ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'Pickup: ${donation['pickupAddress'] ?? 'No address'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Request this donation
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Request for ${donation['foodType']} submitted!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Request This Food'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

// --- NGO Transactions Screen ---
class NGOTransactionsScreen extends StatefulWidget {
  const NGOTransactionsScreen({super.key});

  @override
  State<NGOTransactionsScreen> createState() => _NGOTransactionsScreenState();
}

class _NGOTransactionsScreenState extends State<NGOTransactionsScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);

    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        transactions = await ApiService.getNGOTransactions(stateUser.id);
        error = null;
      } else {
        error = 'NGO not logged in';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.subtleLight),
                    const SizedBox(height: 16),
                    Text(error!, style: const TextStyle(color: AppColors.subtleLight)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadTransactions,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No transactions yet', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Transaction #${transaction['id'] ?? 'Unknown'}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foregroundLight,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${transaction['foodType'] ?? 'Unknown'} - ${transaction['quantity'] ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.foregroundLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${transaction['date'] ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'Status: ${transaction['status'] ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

// --- About Us Screen ---
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FoodLink',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save Food, Share Love',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mission Section
            Text(
              'Our Mission',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'FoodLink connects food donors with NGOs and individuals in need, creating a sustainable solution to reduce food waste while helping communities access nutritious food. We believe that no food should go to waste when people are hungry.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.foregroundLight,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vision Section
            Text(
              'Our Vision',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'A world where surplus food nourishes communities, strengthens bonds, and creates a more sustainable future for everyone.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.foregroundLight,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Team Section
            Text(
              'Our Team',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'FoodLink is built by a passionate team of developers, designers, and community advocates who are committed to making a positive impact on food security and sustainability.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.foregroundLight,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Contact Section
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: AppColors.primary),
                      title: Text(
                        'Email',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foregroundLight,
                        ),
                      ),
                      subtitle: Text(
                        'support@foodlink.app',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.subtleLight,
                        ),
                      ),
                      onTap: () {
                        // Launch email
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                    ListTile(
                      leading: Icon(Icons.phone, color: AppColors.primary),
                      title: Text(
                        'Phone',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foregroundLight,
                        ),
                      ),
                      subtitle: Text(
                        '+1 (555) 123-FOOD',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.subtleLight,
                        ),
                      ),
                      onTap: () {
                        // Launch phone
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                'FoodLink v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.subtleLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Admin Dashboard Screen ---
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Admin Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, AppStrings.routeLogin)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 1,
                    color: AppColors.cardLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '1,247',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Total Users',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.subtleLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 1,
                    color: AppColors.cardLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '892',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Donations',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.subtleLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Admin Actions
            Text(
              'Admin Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 16),

            // Verify NGOs Card
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.verified_user, color: AppColors.primary),
                title: Text(
                  'Verify NGOs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foregroundLight,
                  ),
                ),
                subtitle: Text(
                  'Review and approve new NGO registrations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NGO verification screen coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // All Transactions Card
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.analytics, color: AppColors.primary),
                title: Text(
                  'All Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foregroundLight,
                  ),
                ),
                subtitle: Text(
                  'View platform-wide transaction data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All transactions screen coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Manage Reports Card
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.assessment, color: AppColors.primary),
                title: Text(
                  'Manage Reports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foregroundLight,
                  ),
                ),
                subtitle: Text(
                  'Generate and view platform reports',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reports management screen coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeLogin, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Admin Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
