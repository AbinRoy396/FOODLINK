import 'package:flutter/material.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- Admin Detail Screens ---

// --- Admin: Verify NGOs Screen ---
class AdminVerifyNGOScreen extends StatefulWidget {
  const AdminVerifyNGOScreen({super.key});

  @override
  State<AdminVerifyNGOScreen> createState() => _AdminVerifyNGOScreenState();
}

class _AdminVerifyNGOScreenState extends State<AdminVerifyNGOScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> pendingNGOs = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPendingNGOs();
  }

  Future<void> _loadPendingNGOs() async {
    setState(() => isLoading = true);

    try {
      // Load pending NGO registrations for admin verification
      pendingNGOs = [
        {
          'id': '1',
          'name': 'Green Earth Foundation',
          'email': 'contact@greenearth.org',
          'address': '123 Eco Street, Green City',
          'licenseNumber': 'NGO-2024-001',
          'registrationDate': '2024-01-15',
        },
        {
          'id': '2',
          'name': 'Food For All Network',
          'email': 'info@foodforall.org',
          'address': '456 Community Ave, Hope Town',
          'licenseNumber': 'NGO-2024-002',
          'registrationDate': '2024-01-16',
        },
      ];
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _verifyNGO(String ngoId, bool approved) async {
    try {
      // Verify NGO logic here
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NGO ${approved ? 'approved' : 'rejected'} successfully!')),
      );
      _loadPendingNGOs(); // Refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update NGO: $e')),
      );
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
          'Verify NGOs',
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
                      onPressed: _loadPendingNGOs,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : pendingNGOs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No pending NGO verifications', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pendingNGOs.length,
                        itemBuilder: (context, index) {
                          final ngo = pendingNGOs[index];
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
                                      Expanded(
                                        child: Text(
                                          ngo['name'] ?? 'Unknown NGO',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.foregroundLight,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Pending',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Email: ${ngo['email'] ?? 'No email'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'License: ${ngo['licenseNumber'] ?? 'No license'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'Registered: ${ngo['registrationDate'] ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _verifyNGO(ngo['id'], true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _verifyNGO(ngo['id'], false),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
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

// --- Admin: All Transactions Screen ---
class AdminAllTransactionsScreen extends StatefulWidget {
  const AdminAllTransactionsScreen({super.key});

  @override
  State<AdminAllTransactionsScreen> createState() => _AdminAllTransactionsScreenState();
}

class _AdminAllTransactionsScreenState extends State<AdminAllTransactionsScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> allTransactions = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    setState(() => isLoading = true);

    try {
      // Load all platform transactions
      allTransactions = [
        {
          'id': 'TXN-001',
          'type': 'Donation',
          'foodType': 'Fresh Vegetables',
          'quantity': '25 kg',
          'donor': 'Green Grocers',
          'ngo': 'Food For All Network',
          'receiver': 'Community Center',
          'date': '2024-01-15',
          'status': 'Completed',
        },
        {
          'id': 'TXN-002',
          'type': 'Request',
          'foodType': 'Packaged Meals',
          'quantity': '50 servings',
          'donor': 'Local Restaurant',
          'ngo': 'Green Earth Foundation',
          'receiver': 'Homeless Shelter',
          'date': '2024-01-16',
          'status': 'In Progress',
        },
      ];
      error = null;
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
          'All Transactions',
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
                      onPressed: _loadAllTransactions,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : allTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No transactions found', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: allTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = allTransactions[index];
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
                                        'Transaction ${transaction['id']}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foregroundLight,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(transaction['status']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          transaction['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(transaction['status']),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${transaction['foodType']} - ${transaction['quantity']}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.foregroundLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Donor: ${transaction['donor']}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'NGO: ${transaction['ngo']}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  Text(
                                    'Receiver: ${transaction['receiver']}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${transaction['date']}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.primary;
      case 'in progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.subtleLight;
    }
  }
}

// --- Admin: Manage Reports Screen ---
class AdminManageReportsScreen extends StatefulWidget {
  const AdminManageReportsScreen({super.key});

  @override
  State<AdminManageReportsScreen> createState() => _AdminManageReportsScreenState();
}

class _AdminManageReportsScreenState extends State<AdminManageReportsScreen>
    with AutomaticKeepAliveClientMixin {

  String _selectedPeriod = 'This Month';
  String _selectedReportType = 'Donations Summary';

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
          'Manage Reports',
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
            Text(
              'Generate Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Report Type Selection
                    DropdownButtonFormField<String>(
                      value: _selectedReportType,
                      decoration: InputDecoration(
                        labelText: 'Report Type',
                        filled: true,
                        fillColor: AppColors.inputLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Donations Summary', child: Text('Donations Summary')),
                        DropdownMenuItem(value: 'User Activity', child: Text('User Activity')),
                        DropdownMenuItem(value: 'NGO Performance', child: Text('NGO Performance')),
                        DropdownMenuItem(value: 'Food Waste Impact', child: Text('Food Waste Impact')),
                      ],
                      onChanged: (value) => setState(() => _selectedReportType = value!),
                    ),
                    const SizedBox(height: 16),

                    // Time Period Selection
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: InputDecoration(
                        labelText: 'Time Period',
                        filled: true,
                        fillColor: AppColors.inputLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                        DropdownMenuItem(value: 'Last Month', child: Text('Last Month')),
                        DropdownMenuItem(value: 'This Year', child: Text('This Year')),
                      ],
                      onChanged: (value) => setState(() => _selectedPeriod = value!),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Generating ${_selectedReportType} report...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 16),

            // Sample Reports List
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.analytics, color: AppColors.primary),
                    title: Text(
                      'Donations Summary - January 2024',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      '892 donations, 2.3 tons of food distributed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report download requires backend integration')),
                        );
                      },
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.people, color: AppColors.primary),
                    title: Text(
                      'User Activity - This Month',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      '1,247 active users, 156 new registrations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report download requires backend integration')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Platform Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 16),

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
                            '2.3 tons',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Food Saved',
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
            const SizedBox(height: 16),

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
                            'Active Users',
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
                            '156',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'NGOs',
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
          ],
        ),
      ),
    );
  }
}
