import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/state_preservation_mixin.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- Profile Screens ---

// --- Donor Profile Screen ---
class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen>
    with AutomaticKeepAliveClientMixin {

  UserModel? profile;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<UserState>().user;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      profile = await ApiService.getProfile(user.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userState = context.watch<UserState>();
    final user = userState.user;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null || profile == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Profile',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Container(
                width: 128,
                height: 128,
                color: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            Text(
              'Donor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.subtleLight,
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    title: Text(
                      'Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.address ?? 'Not provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Card
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Your Impact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '12',
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
                        Column(
                          children: [
                            Text(
                              '45 kg',
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NGO Profile Screen ---
class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen>
    with AutomaticKeepAliveClientMixin {

  UserModel? profile;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<UserState>().user;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      profile = await ApiService.getProfile(user.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userState = context.watch<UserState>();
    final user = userState.user;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null || profile == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Profile',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Container(
                width: 128,
                height: 128,
                color: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.business,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            Text(
              'NGO',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.subtleLight,
              ),
            ),
            const SizedBox(height: 32),

            // Organization Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Organization Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Organization Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    title: Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    title: Text(
                      'Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.address ?? 'Not provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Impact Stats
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Your Impact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '156',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Allocations',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '2.3 tons',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Food Distributed',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Receiver Profile Screen ---
class ReceiverProfileScreen extends StatefulWidget {
  const ReceiverProfileScreen({super.key});

  @override
  State<ReceiverProfileScreen> createState() => _ReceiverProfileScreenState();
}

class _ReceiverProfileScreenState extends State<ReceiverProfileScreen>
    with AutomaticKeepAliveClientMixin {

  UserModel? profile;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<UserState>().user;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      profile = await ApiService.getProfile(user.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userState = context.watch<UserState>();
    final user = userState.user;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null || profile == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Profile',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Container(
                width: 128,
                height: 128,
                color: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.volunteer_activism,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile!.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            Text(
              'Receiver',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.subtleLight,
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    title: Text(
                      'Delivery Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      profile!.address ?? 'Not provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Card
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Your Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '8',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Requests',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '6',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Received',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.subtleLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
