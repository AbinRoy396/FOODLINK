import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/state_preservation_mixin.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- NGO Operation Screens ---

// --- Verify Donations Screen (NGO) ---
class VerifyDonationsScreen extends StatefulWidget {
  const VerifyDonationsScreen({super.key});

  @override
  State<VerifyDonationsScreen> createState() => _VerifyDonationsScreenState();
}

class _VerifyDonationsScreenState extends State<VerifyDonationsScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> pendingDonations = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPendingDonations();
  }

  Future<void> _loadPendingDonations() async {
    setState(() => isLoading = true);

    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        // Load pending donations for NGO to verify
        pendingDonations = await ApiService.getPendingDonations();
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

  Future<void> _verifyDonation(String donationId, bool approved) async {
    try {
      await ApiService.verifyDonation(donationId, approved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation ${approved ? 'approved' : 'rejected'}')),
      );
      _loadPendingDonations(); // Refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update donation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Donations'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
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
                      onPressed: _loadPendingDonations,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : isLoading
                ? const Center(child: CircularProgressIndicator())
                : pendingDonations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.subtleLight),
                            const SizedBox(height: 16),
                            Text('No pending donations', style: TextStyle(color: AppColors.subtleLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pendingDonations.length,
                        itemBuilder: (context, index) {
                          final donation = pendingDonations[index];
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
                                        donation.foodType,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        donation.quantity,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.subtleLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    donation.pickupAddress,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.subtleLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _verifyDonation(donation.id, true),
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
                                          onPressed: () => _verifyDonation(donation.id, false),
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

// --- Allocate Requests Screen (NGO) ---
class AllocateRequestsScreen extends StatefulWidget {
  const AllocateRequestsScreen({super.key});

  @override
  State<AllocateRequestsScreen> createState() => _AllocateRequestsScreenState();
}

class _AllocateRequestsScreenState extends State<AllocateRequestsScreen>
    with AutomaticKeepAliveClientMixin {

  List<dynamic> verifiedDonations = [];
  List<dynamic> pendingRequests = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        // Load verified donations and pending requests for allocation
        verifiedDonations = await ApiService.getVerifiedDonations();
        pendingRequests = await ApiService.getPendingRequests();
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

  Future<void> _allocateFood(String donationId, String requestId) async {
    try {
      await ApiService.allocateFood(donationId, requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food allocated successfully!')),
      );
      _loadData(); // Refresh data
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to allocate food: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Food'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          children: [
            Expanded(
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
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            // Donations Column
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    color: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      'Verified Donations',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: verifiedDonations.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.inventory, size: 48, color: AppColors.subtleLight),
                                                const SizedBox(height: 8),
                                                Text('No donations', style: TextStyle(color: AppColors.subtleLight)),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: verifiedDonations.length,
                                            itemBuilder: (context, index) {
                                              final donation = verifiedDonations[index];
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                child: ListTile(
                                                  title: Text(donation.foodType),
                                                  subtitle: Text(donation.quantity),
                                                  trailing: const Icon(Icons.arrow_forward),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Container(
                              width: 1,
                              color: AppColors.borderLight,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            // Requests Column
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    color: Colors.orange.withOpacity(0.1),
                                    child: Text(
                                      'Pending Requests',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: pendingRequests.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.pending, size: 48, color: AppColors.subtleLight),
                                                const SizedBox(height: 8),
                                                Text('No requests', style: TextStyle(color: AppColors.subtleLight)),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: pendingRequests.length,
                                            itemBuilder: (context, index) {
                                              final request = pendingRequests[index];
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                child: ListTile(
                                                  title: Text(request['foodType'] ?? 'Unknown'),
                                                  subtitle: Text(request['quantity'] ?? 'Unknown'),
                                                  trailing: ElevatedButton(
                                                    onPressed: () {
                                                      // Show allocation dialog
                                                      _showAllocationDialog(request);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primary,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text('Allocate'),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllocationDialog(dynamic request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocate Food'),
        content: Text('Allocate food to this request for ${request['foodType']} (${request['quantity']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Allocate logic here
            },
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }
}
