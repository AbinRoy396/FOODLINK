import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/theme_provider.dart';
import 'services/search_filter_service.dart';
import 'models/donation_model.dart';
import 'models/request_model.dart';
import 'models/sort_option.dart';
import 'models/user_model.dart';
import 'services/offline_queue.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/offline_indicator.dart';
import 'widgets/search_filter_widget.dart';
import 'utils/app_strings.dart';
import 'utils/app_colors.dart';
import 'utils/error_handler.dart';
import 'screens/registration_screens.dart';
import 'screens/dashboard/dashboard_screens.dart';
import 'screens/donation_detail_screen.dart';
import 'screens/enhanced_map_screen.dart';
import 'screens/nearby_donations_screen.dart';
import 'services/location_service.dart';
import 'utils/validators.dart';
import 'user_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width, height;
  final BoxFit fit;
  final Widget? placeholder;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? Shimmer.fromColors(
        baseColor: AppColors.borderLight,
        highlightColor: AppColors.backgroundLight,
      child: Container(
          color: AppColors.iconBackgroundLight,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.iconBackgroundLight,
        child: const Icon(Icons.broken_image, color: AppColors.subtleLight),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String buttonText;
  final VoidCallback onPressed;

  const DashboardCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CustomCachedImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              placeholder: Shimmer.fromColors(
                baseColor: AppColors.borderLight,
                highlightColor: AppColors.backgroundLight,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: AppColors.iconBackgroundLight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
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

class DonationListItem extends StatelessWidget {
  final DonationModel donation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const DonationListItem({
    super.key,
    required this.donation,
    this.onTap,
    this.onDelete,
    this.onShare,
  });

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

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case AppStrings.statusPending:
        return AppColors.statusPending.withOpacity(0.1);
      case AppStrings.statusVerified:
        return AppColors.statusVerified.withOpacity(0.1);
      case AppStrings.statusAllocated:
        return AppColors.statusAllocated.withOpacity(0.1);
      case AppStrings.statusDelivered:
        return AppColors.statusDelivered.withOpacity(0.1);
      case AppStrings.statusExpired:
        return AppColors.statusExpired.withOpacity(0.1);
      default:
        return AppColors.backgroundLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(donation.status);
    final statusBgColor = _getStatusBackgroundColor(donation.status);

    final cardWidget = Card(
        elevation: 1,
        color: AppColors.cardLight,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap != null ? () {
            PerformanceUtils.triggerHapticFeedback();
            onTap!();
          } : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Hero(
                  tag: 'donation_${donation.id}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.iconBackgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fastfood, size: 30, color: AppColors.subtleLight),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.foodType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${donation.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subtleLight,
                        ),
                      ),
                      Text(
                        'Pickup: ${donation.pickupAddress}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.subtleLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        donation.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      donation.createdAt.split('T').first,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

    // Wrap with Slidable if delete or share callbacks are provided
    if (onDelete != null || onShare != null) {
      return Slidable(
        key: ValueKey(donation.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onShare != null)
              SlidableAction(
                onPressed: (context) {
                  PerformanceUtils.triggerHapticFeedback();
                  onShare!();
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: 'Share',
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (context) {
                  PerformanceUtils.triggerHapticFeedback();
                  onDelete!();
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
          ],
        ),
        child: Semantics(
          button: onTap != null,
          label: 'Donation item for ${donation.foodType}, quantity ${donation.quantity}, status ${donation.status}',
          hint: onTap != null ? 'Double tap to view details. Swipe left for actions.' : null,
          child: cardWidget,
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      label: 'Donation item for ${donation.foodType}, quantity ${donation.quantity}, status ${donation.status}',
      hint: onTap != null ? 'Double tap to view details' : null,
      child: cardWidget,
    );
  }
}

// --- State Preservation Mixin ---
mixin StatePreservationMixin<T extends StatefulWidget> on State<T> {
  @override
  bool get wantKeepAlive => true;

  @override
  void updateKeepAlive() {
    // This method is called when the widget's keep alive state changes
  }
}

// --- Performance Utilities ---
class PerformanceUtils {
  static const int itemsPerPage = 20;
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  static void triggerHapticFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback not available: $e');
    }
  }
}

// --- Main App Widget ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  debugPrint('🚀 Starting FoodLink App...');
  
  // Note: Firebase features are disabled until google-services.json is added
  // The app will work with all features except: Chat, Notifications, Cloud Storage
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserState()..loadUser()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const FoodLinkApp(),
    ),
  );
}

class FoodLinkApp extends StatefulWidget {
  const FoodLinkApp({super.key});

  @override
  State<FoodLinkApp> createState() => _FoodLinkAppState();
}

class _FoodLinkAppState extends State<FoodLinkApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Setup session expiry callback
    ApiService.onSessionExpired = _handleSessionExpiry;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - sync offline queue
      ApiService.syncOfflineQueue();
    }
  }

  void _handleSessionExpiry() {
    // Navigate to login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppStrings.routeLogin,
      (route) => false,
    );
    
    // Show message
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: AppStrings.appName,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppStrings.routeHome,
      routes: {
        AppStrings.routeHome: (context) => const FoodLinkSplashScreen(),
        AppStrings.routeRoleSelection: (context) => const UserRoleSelectionScreen(),
        AppStrings.routeLogin: (context) => const LoginScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        AppStrings.routeRegisterDonor: (context) => const DonorRegistrationScreen(),
        AppStrings.routeRegisterNGO: (context) => const NGORegistrationScreen(),
        AppStrings.routeRegisterReceiver: (context) => const ReceiverRegistrationScreen(),
        AppStrings.routeDonorDashboard: (context) => const DonorHomeDashboard(),
        AppStrings.routeReceiverDashboard: (context) => const ReceiverHomeDashboard(),
        AppStrings.routeNGODashboard: (context) => const NGOHomeDashboard(),
        AppStrings.routeCreateDonation: (context) => const CreateDonationScreen(),
        AppStrings.routeViewDonations: (context) => ViewDonationsScreen(),
        AppStrings.routeCreateRequest: (context) => const CreateRequestScreen(),
        AppStrings.routeTrackRequestStatus: (context) => const TrackRequestStatusScreen(),
        '/map': (context) => const MapScreen(),
        AppStrings.routeDonorProfile: (context) => const DonorProfileScreen(),
        AppStrings.routeNGOProfile: (context) => const NGOProfileScreen(),
        AppStrings.routeReceiverProfile: (context) => const ReceiverProfileScreen(),
      },
        );
      },
    );
  }
}

// --- Splash Screen ---
class FoodLinkSplashScreen extends StatefulWidget {
  const FoodLinkSplashScreen({super.key});

  @override
  State<FoodLinkSplashScreen> createState() => _FoodLinkSplashScreenState();
}

class _FoodLinkSplashScreenState extends State<FoodLinkSplashScreen>
    with StatePreservationMixin {

  @override
  void initState() {
    super.initState();
    // Start offline sync listener once app starts
    OfflineQueueService.ensureConnectivityListener((op) async {
      await ApiService.syncOfflineQueue();
      return true;
    });
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userState = context.read<UserState>();
    await userState.loadUser();
    
    if (!mounted) return;
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    if (userState.user != null) {
      String route = AppStrings.routeDonorDashboard;
      switch (userState.user!.role) {
        case AppStrings.roleNGO:
          route = AppStrings.routeNGODashboard;
          break;
        case AppStrings.roleReceiver:
          route = AppStrings.routeReceiverDashboard;
          break;
      }
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, AppStrings.routeRoleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomCachedImage(
                imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fastfood, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: GoogleFonts.workSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  style: GoogleFonts.workSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.backgroundDark,
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

// --- User Role Selection Screen ---
class UserRoleSelectionScreen extends StatelessWidget {
  const UserRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.foregroundLight,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.foregroundLight),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Your Role',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foregroundLight,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your role to get started with FoodLink',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.foregroundLight.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Donor Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterDonor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Donor',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // NGO Button
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterNGO),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            foregroundColor: AppColors.foregroundLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'NGO',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Receiver Button
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterReceiver),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            foregroundColor: AppColors.foregroundLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Receiver',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.foregroundLight.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.backgroundLight,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.foregroundLight.withOpacity(0.6),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box_outlined),
                  label: 'Post',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with StatePreservationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      setState(() => _loading = true);
      try {
        final loginData = await ApiService.login(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole!,
        );
        if (loginData != null) {
          await context.read<UserState>().login(loginData);
          String route = '';
          switch (_selectedRole) {
            case AppStrings.roleDonor:
              route = AppStrings.routeDonorDashboard;
              break;
            case AppStrings.roleNGO:
              route = AppStrings.routeNGODashboard;
              break;
            case AppStrings.roleReceiver:
              route = AppStrings.routeReceiverDashboard;
              break;
          }
          if (route.isNotEmpty) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, route);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged in successfully!')),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role and fill fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.backgroundLight,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.foregroundLight,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Please log in.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.subtleLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        // Email Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtleLight,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'you@example.com',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Password Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtleLight,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty) ? 'Please enter your password' : null,
                              ),
                            ],
                          ),
                        ),

                        // Role Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtleLight,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  hintText: 'Select your role',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.borderLight),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                items: const [AppStrings.roleDonor, AppStrings.roleNGO, AppStrings.roleReceiver]
                                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                    .toList(),
                                onChanged: (value) => setState(() => _selectedRole = value),
                                validator: (value) => value == null ? 'Please select a role' : null,
                              ),
                            ],
                          ),
                        ),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppStrings.routeRoleSelection),
                        child: Text(
                          'Don\'t have an account? Register',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                        child: Text(
                          'Admin Login',
                          style: TextStyle(
                            color: AppColors.subtleLight,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Admin Login Screen ---
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        // Admin login logic here
        // For now, just navigate to admin dashboard
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin logged in successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.backgroundLight,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          // Admin Badge Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Admin Portal',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.foregroundLight,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Secure administrator access',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.subtleLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          // Email Field
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Email',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subtleLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'admin@foodlink.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.borderLight),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.borderLight),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter admin email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Password Field
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subtleLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.borderLight),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.borderLight),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty) ? 'Please enter password' : null,
                                ),
                              ],
                            ),
                          ),

                          // Login Button
                          ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Admin Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppStrings.routeLogin),
                      child: Text(
                        'Back to user login',
                        style: TextStyle(
                          color: AppColors.subtleLight,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Registration Screens ---
class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() => _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen>
    with StatePreservationMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final registerData = await ApiService.register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: AppStrings.roleDonor,
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          ErrorHandler.showSuccess(context, 'Welcome to FoodLink! Registration successful.');
          Navigator.pushReplacementNamed(context, AppStrings.routeDonorDashboard);
        }
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.showError(context, e);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),
                      // Phone Field
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Phone',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Address',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer with button
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                                        style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeLogin),
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: AppColors.subtleLight,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NGORegistrationScreen extends StatefulWidget {
  const NGORegistrationScreen({super.key});

  @override
  State<NGORegistrationScreen> createState() => _NGORegistrationScreenState();
}

class _NGORegistrationScreenState extends State<NGORegistrationScreen>
    with StatePreservationMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final registerData = await ApiService.register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: AppStrings.roleNGO,
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppStrings.routeNGODashboard);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registered successfully!')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Registration'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Organization Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Organization Name',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter organization name' : null,
                      ),
                      const SizedBox(height: 24),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),
                      // Phone
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Address',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // License Document Upload
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'License Document (Upload)',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: Icon(Icons.upload_file, color: AppColors.subtleLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Register as Donor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiverRegistrationScreen extends StatefulWidget {
  const ReceiverRegistrationScreen({super.key});

  @override
  State<ReceiverRegistrationScreen> createState() => _ReceiverRegistrationScreenState();
}

class _ReceiverRegistrationScreenState extends State<ReceiverRegistrationScreen>
    with StatePreservationMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final registerData = await ApiService.register(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: AppStrings.roleReceiver,
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppStrings.routeReceiverDashboard);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registered successfully!')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.foregroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 24),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),
                      // Phone
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Phone',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Delivery Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Delivery Address',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                                        style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppStrings.routeLogin),
                    child: Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: AppColors.subtleLight,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Screens ---
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
      // Chat disabled - enable after Firebase setup
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => ChatListScreen(
      //           currentUserId: user.id.toString(),
      //           currentUserName: user.name,
      //         ),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.chat),
      //   tooltip: 'Messages',
      // ),
    );
  }
}

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

// --- Donation Management Screens ---
class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> 
    with StatePreservationMixin {
  
  final _formKey = GlobalKey<FormState>();
  String? _foodType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _pickupAddressController = TextEditingController();
  final TextEditingController _expiryTimeController = TextEditingController();
  bool _loading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _quantityController.dispose();
    _pickupAddressController.dispose();
    _expiryTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                // Photo upload disabled - enable after Firebase setup
                // final image = await PhotoUploadService.pickImageFromGallery();
                // if (image != null) setState(() => _selectedImage = image);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload requires Firebase setup')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                // Photo upload disabled - enable after Firebase setup
                // final image = await PhotoUploadService.pickImageFromCamera();
                // if (image != null) setState(() => _selectedImage = image);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload requires Firebase setup')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate() && _foodType != null) {
      setState(() => _loading = true);
      try {
        // Upload image if selected
        // Photo upload disabled - enable after Firebase setup
        // if (_selectedImage != null) {
        //   final user = context.read<UserState>().user;
        //   if (user != null) {
        //     _uploadedImageUrl = await PhotoUploadService.uploadImage(
        //       imageFile: _selectedImage!,
        //       userId: user.id.toString(),
        //       folder: 'donations',
        //     );
        //   }
        // }

        final donation = await ApiService.createDonation(
          foodType: _foodType!,
          quantity: _quantityController.text,
          pickupAddress: _pickupAddressController.text,
          expiryTime: _expiryTimeController.text,
        );
        if (donation != null) {
          // Log analytics (disabled - enable after Firebase setup)
          // await AnalyticsService.logDonationCreated(
          //   foodType: _foodType!,
          //   quantity: _quantityController.text,
          // );
          
          if (!mounted) return;
          ErrorHandler.showSuccess(
            context,
            _uploadedImageUrl != null 
              ? 'Donation created with photo!' 
              : 'Donation created successfully!',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.showError(context, e);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      ErrorHandler.showWarning(context, 'Please fill all fields and select food type.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Donation'),
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Food Type', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _foodType,
                decoration: const InputDecoration(hintText: 'Select Food Type'),
                items: const <String>['Fruits & Vegetables', 'Packaged Meals', 'Bakery Items', 'Dairy Products']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _foodType = newValue);
                },
                validator: (value) => value == null ? 'Please select a food type' : null,
              ),
              const SizedBox(height: 16),
              Text('Quantity', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  hintText: 'e.g., 5 kg',
                  helperText: 'Enter quantity with unit (kg, liters, servings)',
                ),
                keyboardType: TextInputType.text,
                validator: Validators.validateQuantity,
              ),
              const SizedBox(height: 16),
              Text('Pickup Address', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pickupAddressController,
                decoration: const InputDecoration(
                  hintText: 'Enter full address',
                  helperText: 'Include street, city, and postal code',
                ),
                maxLines: 2,
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: 16),
              Text('Expiry Time', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expiryTimeController,
                readOnly: true,
                decoration: const InputDecoration(hintText: 'Best before date/time'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && mounted) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final dateStr = "${pickedDate.toLocal().toString().split(' ')[0]}";
                      final hour = pickedTime.hour.toString().padLeft(2, '0');
                      final minute = pickedTime.minute.toString().padLeft(2, '0');
                      _expiryTimeController.text = "$dateStr $hour:$minute";
                    }
                  }
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter expiry time' : null,
              ),
              const SizedBox(height: 16),
              Text('Food Photo (Optional)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Food Photo'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submitDonation,
                                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),),
                child: _loading ? const CircularProgressIndicator() : const Text('Create Donation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewDonationsScreen extends StatefulWidget {
  const ViewDonationsScreen({super.key});

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen> 
    with AutomaticKeepAliveClientMixin {
  
  List<DonationModel> donations = [];
  List<DonationModel> filteredDonations = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String? error;
  String searchQuery = '';
  List<String> statusFilters = [];
  SortOption sortBy = SortOption.dateNewest;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => isLoading = true);
    
    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        donations = await ApiService.getUserDonations(stateUser.id);
        _applyFilters();
        error = null;
      } else {
        error = 'User not logged in';
      }
    } catch (e) {
      error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load donations: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _loadDonations(showLoading: false),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  void _applyFilters() {
    filteredDonations = SearchFilterService.applyFilters(
      donations: donations,
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
      statusFilters: statusFilters.isEmpty ? null : statusFilters,
      sortBy: sortBy,
    );
  }

  Future<void> _refreshDonations() async {
    setState(() => isRefreshing = true);
    PerformanceUtils.triggerHapticFeedback();
    await _loadDonations(showLoading: false);
  }

  Future<void> _deleteDonation(DonationModel donation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donation?'),
        content: Text('Are you sure you want to delete "${donation.foodType}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
                                style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Log analytics (disabled - enable after Firebase setup)
        // await AnalyticsService.logDonationDeleted(donation.id.toString());
        
        // Remove from local list (API call would go here)
        setState(() {
          donations.removeWhere((d) => d.id == donation.id);
          _applyFilters();
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  void _shareDonation(DonationModel donation) {
    // AnalyticsService.logDonationShared(donation.id.toString());
    Share.share(
      'Check out this food donation!\n\n'
      '🍽️ Food Type: ${donation.foodType}\n'
      '📦 Quantity: ${donation.quantity}\n'
      '📍 Pickup: ${donation.pickupAddress}\n'
      '⏰ Expires: ${donation.expiryTime}\n'
      '✅ Status: ${donation.status}\n\n'
      'Help reduce food waste with FoodLink!',
      subject: 'Food Donation - ${donation.foodType}',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentDonations = filteredDonations.where((d) => d.status != 'Delivered' && d.status != 'Expired').toList();
    final pastDonations = filteredDonations.where((d) => d.status == 'Delivered' || d.status == 'Expired').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
          title: const Text('My Donations'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new), 
            onPressed: () => Navigator.pop(context)
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subtleLight,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Current'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: Column(
          children: [
            SearchFilterWidget(
              onSearchChanged: (query) {
                setState(() {
                  searchQuery = query;
                  _applyFilters();
                });
              },
              onStatusFilterChanged: (filters) {
                setState(() {
                  statusFilters = filters;
                  _applyFilters();
                });
              },
              onSortChanged: (sort) {
                setState(() {
                  sortBy = sort;
                  _applyFilters();
                });
              },
            ),
            Expanded(
              child: error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: AppColors.statusExpired),
                          const SizedBox(height: 16),
                          Text(error!, style: const TextStyle(color: AppColors.subtleLight)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshDonations,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      children: [
                        // Current Donations Tab
                        isLoading
                          ? ListView.builder(
                              itemCount: 5,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: ListTile(
                                    leading: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    title: Container(
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                    subtitle: Container(
                                      height: 12,
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(top: 8),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshDonations,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: currentDonations.isEmpty
                                  ? ListView(
                                      key: const ValueKey('empty_current'),
                                      children: const [
                                        SizedBox(height: 100),
                                        Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.inbox_outlined, size: 64, color: AppColors.subtleLight),
                                              SizedBox(height: 16),
                                              Text('No current donations', style: TextStyle(color: AppColors.subtleLight)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      key: const PageStorageKey('current_donations_list'),
                                      padding: const EdgeInsets.all(16),
                                      itemCount: currentDonations.length,
                                      itemBuilder: (context, index) => DonationListItem(
                                        donation: currentDonations[index],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DonationDetailScreen(donation: currentDonations[index]),
                                            ),
                                          );
                                        },
                                        onDelete: () => _deleteDonation(currentDonations[index]),
                                        onShare: () => _shareDonation(currentDonations[index]),
                                      ),
                                    ),
                              ),
                            ),
                        // Past Donations Tab
                        isLoading
                          ? ListView.builder(
                              itemCount: 5,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: ListTile(
                                    leading: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    title: Container(
                                      height: 16,
                                      color: Colors.white,
                                    ),
                                    subtitle: Container(
                                      height: 12,
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(top: 8),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshDonations,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: pastDonations.isEmpty
                                  ? ListView(
                                      key: const ValueKey('empty_past'),
                                      children: const [
                                        SizedBox(height: 100),
                                        Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.history, size: 64, color: AppColors.subtleLight),
                                              SizedBox(height: 16),
                                              Text('No past donations', style: TextStyle(color: AppColors.subtleLight)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      key: const PageStorageKey('past_donations_list'),
                                      padding: const EdgeInsets.all(16),
                                      itemCount: pastDonations.length,
                                      itemBuilder: (context, index) => DonationListItem(
                                        donation: pastDonations[index],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DonationDetailScreen(donation: pastDonations[index]),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              ),
                            ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Profile Screens ---
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
      appBar: AppBar(
        title: const Text('Profile'),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: CustomCachedImage(
                imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                width: 128,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(profile!.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Donor', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.subtleLight)),
            const SizedBox(height: 32),
            Align(alignment: Alignment.centerLeft, child: Text('Personal Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Email', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(profile!.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleLight)),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  ListTile(
                    title: Text('Address', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(profile!.address ?? 'Not provided', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleLight)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(alignment: Alignment.centerLeft, child: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Switch between light and dark theme'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.chat, color: Theme.of(context).primaryColor),
                    title: const Text('Messages'),
                    subtitle: const Text('Requires Firebase setup'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat requires Firebase setup')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
                                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Profile'),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: CustomCachedImage(
                imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                width: 128,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(profile!.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('NGO • Joined ${profile!.createdAt.split('T').first}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.subtleLight)),
            const SizedBox(height: 32),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
                                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: CustomCachedImage(
                imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                width: 128,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(profile!.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Receiver', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            Text('Joined ${profile!.createdAt.split('T').first}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
            const SizedBox(height: 32),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Personal Information', style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
                    onTap: () {},
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  ListTile(
                    title: Text('Request History', style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
                    onTap: () {},
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  ListTile(
                    title: Text('Delivery Preferences', style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppStrings.routeRoleSelection, (route) => false);
              },
                                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),,
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Request Management Screens ---
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> 
    with StatePreservationMixin {
  
  final _formKey = GlobalKey<FormState>();
  String? _foodType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _foodType != null) {
      setState(() => _loading = true);
      try {
        final request = await ApiService.createRequest(
          foodType: _foodType!,
          quantity: _quantityController.text,
          address: _addressController.text,
          notes: _notesController.text,
        );
        if (request != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request submitted successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select food type.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Food Type', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _foodType,
                decoration: const InputDecoration(hintText: 'Select Food Type'),
                items: const <String>['Vegetables', 'Fruits', 'Dairy Products', 'Bakery Items']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) => setState(() => _foodType = newValue),
                validator: (value) => value == null ? 'Please select a food type' : null,
                ),
                const SizedBox(height: 16),
              Text('Quantity', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
                  TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(hintText: 'e.g., 5 kg'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter quantity' : null,
              ),
                  const SizedBox(height: 16),
              Text('Delivery Address', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                decoration: const InputDecoration(hintText: 'Enter your full address'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter delivery address' : null,
              ),
              const SizedBox(height: 16),
              Text('Additional Notes', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                  maxLines: 4,
                decoration: const InputDecoration(hintText: 'Any special instructions? (optional)'),
                ),
                const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submitRequest,
                                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),, shape: const StadiumBorder()),
                child: _loading ? const CircularProgressIndicator() : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackRequestStatusScreen extends StatefulWidget {
  const TrackRequestStatusScreen({super.key});

  @override
  State<TrackRequestStatusScreen> createState() => _TrackRequestStatusScreenState();
}

class _TrackRequestStatusScreenState extends State<TrackRequestStatusScreen> 
    with AutomaticKeepAliveClientMixin {
  
  List<RequestModel> requests = [];
  bool isLoading = true;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        requests = await ApiService.getUserRequests(stateUser.id);
      } else {
        error = 'User not logged in';
      }
    } catch (e) {
      error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load requests: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final requested = requests.where((r) => r.status == 'Requested').toList();
    final matched = requests.where((r) => r.status == 'Matched').toList();
    final fulfilled = requests.where((r) => r.status == 'Fulfilled').toList();
    final cancelled = requests.where((r) => r.status == 'Cancelled').toList();

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Requests'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), 
            onPressed: () => Navigator.pop(context)
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subtleLight,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Requested'),
              Tab(text: 'Matched'),
              Tab(text: 'Fulfilled'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: error != null
            ? Center(child: Text(error!))
            : TabBarView(
          children: [
                  _buildRequestList(context, requested),
                  _buildRequestList(context, matched),
                  _buildRequestList(context, fulfilled),
                  _buildRequestList(context, cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, List<RequestModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No requests found'));
    }
    return ListView.builder(
        padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        return Card(
          elevation: 0,
          color: AppColors.cardLight,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.food_bank, color: AppColors.primary),
            title: Text('${r.foodType} • ${r.quantity}'),
            subtitle: Text('Address: ${r.address}\nStatus: ${r.status}'),
            trailing: Text(r.createdAt.split('T').first),
          ),
        );
      },
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup & Delivery Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: const LatLng(37.7749, -122.4194),
          zoom: 12,
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
    );
  }
}