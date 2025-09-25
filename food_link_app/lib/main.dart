import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'services/api_service.dart';
import 'user_state.dart';
import 'models/user_model.dart';
import 'models/donation_model.dart';
import 'models/request_model.dart';

// --- Constants ---
class AppStrings {
  static const String appName = 'FoodLink';
  static const String appTagline = 'Save Food, Share Love';
  
  // Routes
  static const String routeHome = '/';
  static const String routeRoleSelection = '/role_selection';
  static const String routeLogin = '/login';
  static const String routeRegisterDonor = '/register_donor';
  static const String routeRegisterNGO = '/register_ngo';
  static const String routeRegisterReceiver = '/register_receiver';
  static const String routeDonorDashboard = '/donor_dashboard';
  static const String routeReceiverDashboard = '/receiver_dashboard';
  static const String routeNGODashboard = '/ngo_dashboard';
  static const String routeCreateDonation = '/create_donation';
  static const String routeViewDonations = '/view_donations';
  static const String routeCreateRequest = '/create_request';
  static const String routeTrackRequestStatus = '/track_request_status';
  static const String routeDonorProfile = '/profile_donor';
  static const String routeNGOProfile = '/profile_ngo';
  static const String routeReceiverProfile = '/profile_receiver';

  // User Roles
  static const String roleDonor = 'Donor';
  static const String roleNGO = 'NGO';
  static const String roleReceiver = 'Receiver';

  // Statuses
  static const String statusPending = 'Pending';
  static const String statusVerified = 'Verified';
  static const String statusAllocated = 'Allocated';
  static const String statusDelivered = 'Delivered';
  static const String statusExpired = 'Expired';
  static const String statusRequested = 'Requested';
  static const String statusMatched = 'Matched';
  static const String statusFulfilled = 'Fulfilled';
  static const String statusCancelled = 'Cancelled';
}

// --- Theme and Colors ---
class AppColors {
  static const Color primary = Color(0xFF11D452);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF102216);
  static const Color foregroundLight = Color(0xFF111813);
  static const Color foregroundDark = Color(0xFFE3E3E3);
  static const Color subtleLight = Color(0xFF61896F);
  static const Color subtleDark = Color(0xFFA0B3A8);
  static const Color borderLight = Color(0xFFDBE6DF);
  static const Color borderDark = Color(0xFF2A3C31);
  static const Color inputLight = Color(0xFFF0F4F2);
  static const Color inputDark = Color(0xFF1A3824);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF182E1F);
  static const Color iconBackgroundLight = Color(0xFFE8F0EB);
  static const Color iconBackgroundDark = Color(0xFF23402C);
  
  // Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusVerified = Color(0xFF2196F3);
  static const Color statusAllocated = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusExpired = Color(0xFFF44336);
}

ThemeData buildAppTheme(BuildContext context) {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: GoogleFonts.workSansTextTheme(
      Theme.of(context).textTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.foregroundLight,
      elevation: 0,
      titleTextStyle: GoogleFonts.workSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.foregroundLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.subtleLight),
      hintStyle: const TextStyle(color: AppColors.subtleLight),
    ),
  );
}

// --- Reusable Widgets ---
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
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(buttonText),
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

  const DonationListItem({
    super.key,
    required this.donation,
    this.onTap,
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

    return Card(
      elevation: 1,
      color: AppColors.cardLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, size: 30, color: AppColors.subtleLight),
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
  }
}

// --- State Preservation Mixin ---
mixin StatePreservationMixin<T extends StatefulWidget> on State<T> {
  @override
  bool get wantKeepAlive => true;
}

// --- Main App Widget ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserState()..loadUser()),
      ],
      child: const FoodLinkApp(),
    ),
  );
}

class FoodLinkApp extends StatelessWidget {
  const FoodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: buildAppTheme(context),
      initialRoute: AppStrings.routeHome,
      routes: {
        AppStrings.routeHome: (context) => const FoodLinkSplashScreen(),
        AppStrings.routeRoleSelection: (context) => const UserRoleSelectionScreen(),
        AppStrings.routeLogin: (context) => const LoginScreen(),
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
        AppStrings.routeDonorProfile: (context) => const DonorProfileScreen(),
        AppStrings.routeNGOProfile: (context) => const NGOProfileScreen(),
        AppStrings.routeReceiverProfile: (context) => const ReceiverProfileScreen(),
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
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Your Role',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your role to get started with FoodLink',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.foregroundLight.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterDonor),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              child: const Text('Donor'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterNGO),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary.withOpacity(0.2),
                foregroundColor: AppColors.foregroundLight,
              ),
              child: const Text('NGO'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeRegisterReceiver),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary.withOpacity(0.2),
                foregroundColor: AppColors.foregroundLight,
              ),
              child: const Text('Receiver'),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeLogin),
              child: const Text(
                'Already have an account? Log In',
                style: TextStyle(
                  color: AppColors.subtleLight,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
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
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Please log in.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    labelText: 'Email',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    labelText: 'Password',
                  ),
                  validator: (value) => 
                      (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  hint: const Text(
                    'Select your role',
                    style: TextStyle(color: AppColors.subtleLight),
                  ),
                  items: const [AppStrings.roleDonor, AppStrings.roleNGO, AppStrings.roleReceiver]
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator: (value) => value == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: _loading ? const CircularProgressIndicator() : const Text('Log In'),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppStrings.routeRoleSelection),
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(
                      color: AppColors.subtleLight,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
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
          Navigator.pushReplacementNamed(context, AppStrings.routeDonorDashboard);
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
      appBar: AppBar(title: const Text('Register as Donor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => 
                    (value == null || value.length < 6) ? 'Password must be at least 6 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ],
          ),
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
      appBar: AppBar(title: const Text('Register as NGO')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => 
                    (value == null || value.length < 6) ? 'Password must be at least 6 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ],
          ),
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
      appBar: AppBar(title: const Text('Register as Receiver')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => 
                    (value == null || value.length < 6) ? 'Password must be at least 6 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ],
          ),
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
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            DashboardCard(
              title: 'My Donations',
              description: 'View and manage your donations.',
              imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
            ),
            const SizedBox(height: 16),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.foregroundLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) Navigator.pushNamed(context, AppStrings.routeDonorProfile);
        },
      ),
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
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Request Food',
              description: 'Submit a request for food assistance.',
              imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Request',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeCreateRequest),
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Available Donations',
              description: 'Browse available food donations.',
              imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Browse',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeViewDonations),
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'My Requests',
              description: 'View and manage your requests.',
              imageUrl: 'https://images.unsplash.com/photo-1581093458799-3b1c04a6d1a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, AppStrings.routeTrackRequestStatus),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
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
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Verify Donations',
              description: 'Confirm incoming donations and update inventory.',
              imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Verify',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Allocate Requests',
              description: 'Assign food to pending requests.',
              imageUrl: 'https://images.unsplash.com/photo-1581093458799-3b1c04a6d1a4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'Allocate',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: 'Transactions',
              description: 'View distribution activities.',
              imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
              buttonText: 'View',
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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

  @override
  void dispose() {
    _quantityController.dispose();
    _pickupAddressController.dispose();
    _expiryTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate() && _foodType != null) {
      setState(() => _loading = true);
      try {
        final donation = await ApiService.createDonation(
          foodType: _foodType!,
          quantity: _quantityController.text,
          pickupAddress: _pickupAddressController.text,
          expiryTime: _expiryTimeController.text,
        );
        if (donation != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donation created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create donation: $e')),
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
                decoration: const InputDecoration(hintText: 'e.g., 5 kg'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter quantity' : null,
              ),
              const SizedBox(height: 16),
              Text('Pickup Address', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pickupAddressController,
                decoration: const InputDecoration(hintText: 'Enter full address'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter pickup address' : null,
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submitDonation,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
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
    try {
      final stateUser = context.read<UserState>().user;
      if (stateUser != null) {
        donations = await ApiService.getUserDonations(stateUser.id);
      } else {
        error = 'User not logged in';
      }
    } catch (e) {
      error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load donations: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentDonations = donations.where((d) => d.status != 'Delivered' && d.status != 'Expired').toList();
    final pastDonations = donations.where((d) => d.status == 'Delivered' || d.status == 'Expired').toList();

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
        body: error != null
            ? Center(child: Text(error!))
            : TabBarView(
                children: [
                  isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentDonations.length,
                        itemBuilder: (context, index) => DonationListItem(donation: currentDonations[index]),
                      ),
                  isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pastDonations.length,
                        itemBuilder: (context, index) => DonationListItem(donation: pastDonations[index]),
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
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
              onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person, size: 64),
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
            const SizedBox(height: 32),
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
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
              onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.business, size: 64),
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
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
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
              onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person, size: 64),
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
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
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), shape: const StadiumBorder()),
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