import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../user_state.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/dashboard_card.dart';
import '../../../widgets/offline_indicator.dart';

// --- Dashboard Screens ---

// --- Donor Home Dashboard ---
class DonorHomeDashboard extends StatefulWidget {
  const DonorHomeDashboard({super.key});

  @override
  State<DonorHomeDashboard> createState() => _DonorHomeDashboardState();
}

class _DonorHomeDashboardState extends State<DonorHomeDashboard>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<UserState>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight.withOpacity(0.9),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.foregroundLight.withOpacity(0.7)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.foregroundLight.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DashboardCard(
                    title: 'Create Donation',
                    description: 'Donate surplus food to those in need.',
                    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                    buttonText: 'Start',
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateDonation),
                  ),
                  const SizedBox(height: 24),
                  DashboardCard(
                    title: 'My Donations',
                    description: 'View and manage your past donations.',
                    imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                    buttonText: 'View',
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
                  ),
                  const SizedBox(height: 24),
                  DashboardCard(
                    title: 'Track Status',
                    description: 'Follow the journey of your donations.',
                    imageUrl: 'https://images.unsplash.com/photo-1581093458799-3b1c04a6d1a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                    buttonText: 'Track',
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.foregroundLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism_outlined), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, AppStrings.routeViewDonations);
          if (index == 2) Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus);
          if (index == 3) Navigator.pushNamed(context, AppStrings.routeDonorProfile);
        },
      ),
    );
  }
}

// --- NGO Home Dashboard ---
class NGOHomeDashboard extends StatefulWidget {
  const NGOHomeDashboard({super.key});

  @override
  State<NGOHomeDashboard> createState() => _NGOHomeDashboardState();
}

class _NGOHomeDashboardState extends State<NGOHomeDashboard>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<UserState>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.foregroundLight),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Verify Donations',
              description: 'Confirm incoming food donations and update inventory.',
              imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Verify',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Allocate Requests',
              description: 'Assign food to pending requests from beneficiaries.',
              imageUrl: 'https://images.unsplash.com/photo-1581093458799-3b1c04a6d1a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Allocate',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Transactions',
              description: 'View all past and current food distribution activities.',
              imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'View',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Feedback',
              description: 'Share your experience and help us improve our services.',
              imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Provide',
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism_outlined), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, AppStrings.routeNGOProfile);
        },
      ),
    );
  }
}

// --- Receiver Home Dashboard ---
class ReceiverHomeDashboard extends StatefulWidget {
  const ReceiverHomeDashboard({super.key});

  @override
  State<ReceiverHomeDashboard> createState() => _ReceiverHomeDashboardState();
}

class _ReceiverHomeDashboardState extends State<ReceiverHomeDashboard>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<UserState>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        elevation: 0,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.foregroundLight),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Request Food',
              description: 'Submit a request for food assistance. Specify your needs and location.',
              imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Request',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateRequest),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Available Donations',
              description: 'Browse available food donations from local businesses and individuals.',
              imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Browse',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'My Requests',
              description: 'View and manage your food requests. Track their status and communicate with donors.',
              imageUrl: 'https://images.unsplash.com/photo-1581093458799-3b1c04a6d1a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight.withOpacity(0.8),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, AppStrings.routeViewDonations);
          if (index == 2) Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus);
          if (index == 3) Navigator.pushNamed(context, AppStrings.routeReceiverProfile);
        },
      ),
    );
  }
}
