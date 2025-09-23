import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'user_state.dart';
import 'models/user_model.dart';
import 'models/donation_model.dart';
import 'models/request_model.dart';

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

// --- Main App Widget ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState()..loadUser(),
      child: const FoodLinkApp(),
    ),
  );
}

class FoodLinkApp extends StatelessWidget {
  const FoodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLink',
      theme: buildAppTheme(context),
      initialRoute: '/',
      routes: {
        '/': (context) => const FoodLinkSplashScreen(),
        '/role_selection': (context) => const UserRoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register_donor': (context) => const DonorRegistrationScreen(),
        '/register_ngo': (context) => const NGORegistrationScreen(),
        '/register_receiver': (context) => const ReceiverRegistrationScreen(),
        '/donor_dashboard': (context) => const DonorHomeDashboard(),
        '/receiver_dashboard': (context) => const ReceiverHomeDashboard(),
        '/ngo_dashboard': (context) => const NGOHomeDashboard(),
        '/create_donation': (context) => const CreateDonationScreen(),
        '/view_donations': (context) => ViewDonationsScreen(),
        '/create_request': (context) => const CreateRequestScreen(),
        '/track_request_status': (context) => const TrackRequestStatusScreen(),
        '/verify_donations_ngo': (context) => const VerifyDonationsScreenNGO(),
        '/allocate_requests_ngo': (context) => const AllocateRequestsScreenNGO(),
        '/transactions_ngo': (context) => const TransactionsScreenNGO(),
        '/feedback_ratings_ngo': (context) => const FeedbackRatingsScreenNGO(),
        '/profile_donor': (context) => const DonorProfileScreen(),
        '/profile_ngo': (context) => const NGOProfileScreen(),
        '/profile_receiver': (context) => const ReceiverProfileScreen(),
        '/general_settings': (context) => const GeneralSettingsScreen(),
        '/app_preferences': (context) => const AppPreferencesScreen(),
        '/notification_settings': (context) => const NotificationSettingsScreen(),
        '/privacy_settings': (context) => const PrivacySettingsScreen(),
        '/account_settings': (context) => const AccountSettingsScreen(),
        '/about_us': (context) => const AboutUsScreen(),
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

class _FoodLinkSplashScreenState extends State<FoodLinkSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userState = context.read<UserState>();
      await userState.loadUser();
      if (!mounted) return;
      if (userState.user != null) {
        String route = '/donor_dashboard';
        switch (userState.user!.role) {
          case 'NGO':
            route = '/ngo_dashboard';
            break;
          case 'Receiver':
            route = '/receiver_dashboard';
            break;
        }
        Navigator.pushReplacementNamed(context, route);
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/role_selection');
          }
        });
      }
    });
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
              child: Image.network(
                'https://via.placeholder.com/400x600?text=FoodLink+Background',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.backgroundLight,
                  child: const Center(child: Icon(Icons.broken_image, size: 80, color: AppColors.subtleLight)),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fastfood, size: 120, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'FoodLink',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save Food, Share Love',
                  style: TextStyle(
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
        title: const Text('FoodLink'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Your Role',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your role to get started with FoodLink',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.foregroundLight.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register_donor'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              child: const Text('Donor'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register_ngo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary.withOpacity(0.2),
                foregroundColor: AppColors.foregroundLight,
              ),
              child: const Text('NGO'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register_receiver'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.primary.withOpacity(0.2),
                foregroundColor: AppColors.foregroundLight,
              ),
              child: const Text('Receiver'),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.foregroundLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {},
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

class _LoginScreenState extends State<LoginScreen> {
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
            case 'Donor':
              route = '/donor_dashboard';
              break;
            case 'NGO':
              route = '/ngo_dashboard';
              break;
            case 'Receiver':
              route = '/receiver_dashboard';
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
                Text('FoodLink', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Welcome back! Please log in.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.subtleLight)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'you@example.com', labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Please enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '••••••••', labelText: 'Password'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  hint: const Text('Select your role', style: TextStyle(color: AppColors.subtleLight)),
                  items: const ['Donor', 'NGO', 'Receiver'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
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
                  onPressed: () => Navigator.pushNamed(context, '/role_selection'),
                  child: const Text('Don\'t have an account? Register', style: TextStyle(color: AppColors.subtleLight, decoration: TextDecoration.underline)),
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

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
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
          role: 'Donor',
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/donor_dashboard');
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
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 chars' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
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

class _NGORegistrationScreenState extends State<NGORegistrationScreen> {
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
          role: 'NGO',
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/ngo_dashboard');
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
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Organization Name'), validator: (v) => v?.isEmpty ?? true ? 'Enter name' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) ? 'Invalid email' : null),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
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

class _ReceiverRegistrationScreenState extends State<ReceiverRegistrationScreen> {
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
          role: 'Receiver',
          address: _addressController.text,
        );
        if (registerData != null) {
          await context.read<UserState>().login(registerData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/receiver_dashboard');
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
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v?.isEmpty ?? true ? 'Enter name' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) ? 'Invalid email' : null),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}

// --- II. Post-Authentication & Dashboard Access ---

// Donor Home Dashboard
class DonorHomeDashboard extends StatelessWidget {
  const DonorHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodLink'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDashboardCard(
              context,
              title: 'Create Donation',
              description: 'Donate surplus food to those in need.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Create+Donation',
              buttonText: 'Start',
              onPressed: () => Navigator.pushNamed(context, '/create_donation'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'My Donations',
              description: 'View and manage your donations.',
              imageUrl: 'https://via.placeholder.com/400x200?text=My+Donations',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, '/view_donations'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Track Status',
              description: 'Follow the journey of your donations.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Track+Status',
              buttonText: 'Track',
              onPressed: () => Navigator.pushNamed(context, '/track_request_status'),
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
          if (index == 3) Navigator.pushNamed(context, '/profile_donor');
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String description, required String imageUrl, required String buttonText, required VoidCallback onPressed}) {
    return Card(
      elevation: 1,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: AppColors.iconBackgroundLight,
                child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: AppColors.subtleLight)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.foregroundLight.withOpacity(0.6))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 14),
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

// Receiver Home Dashboard
class ReceiverHomeDashboard extends StatelessWidget {
  const ReceiverHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodLink'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDashboardCard(
              context,
              title: 'Request Food',
              description: 'Submit a request for food assistance.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Request+Food',
              buttonText: 'Request',
              onPressed: () => Navigator.pushNamed(context, '/create_request'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Available Donations',
              description: 'Browse available food donations.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Available+Donations',
              buttonText: 'Browse',
              onPressed: () => Navigator.pushNamed(context, '/view_donations'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'My Requests',
              description: 'View and manage your requests.',
              imageUrl: 'https://via.placeholder.com/400x200?text=My+Requests',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, '/track_request_status'),
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
          if (index == 3) Navigator.pushNamed(context, '/profile_receiver');
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String description, required String imageUrl, required String buttonText, required VoidCallback onPressed}) {
    return Card(
      elevation: 1,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: AppColors.iconBackgroundLight,
                child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: AppColors.subtleLight)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    textStyle: const TextStyle(fontSize: 14),
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

// NGO Home Dashboard
class NGOHomeDashboard extends StatelessWidget {
  const NGOHomeDashboard({super.key});

  Widget _buildDashboardCard(BuildContext context, {required String title, required String description, required String imageUrl, required String buttonText, required VoidCallback onPressed}) {
    return Card(
      elevation: 1,
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: AppColors.iconBackgroundLight,
                child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: AppColors.subtleLight)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    textStyle: const TextStyle(fontSize: 14),
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodLink'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDashboardCard(
              context,
              title: 'Verify Donations',
              description: 'Confirm incoming donations and update inventory.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Verify+Donations',
              buttonText: 'Verify',
              onPressed: () => Navigator.pushNamed(context, '/verify_donations_ngo'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Allocate Requests',
              description: 'Assign food to pending requests.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Allocate+Requests',
              buttonText: 'Allocate',
              onPressed: () => Navigator.pushNamed(context, '/allocate_requests_ngo'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Transactions',
              description: 'View distribution activities.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Transactions',
              buttonText: 'View',
              onPressed: () => Navigator.pushNamed(context, '/transactions_ngo'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              title: 'Feedback',
              description: 'Share experience and help improve services.',
              imageUrl: 'https://via.placeholder.com/400x200?text=Feedback',
              buttonText: 'Provide',
              onPressed: () => Navigator.pushNamed(context, '/feedback_ratings_ngo'),
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
          if (index == 4) Navigator.pushNamed(context, '/profile_ngo');
        },
      ),
    );
  }
}

// --- III. Core User Flows ---

// Create Donation Screen
class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
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
          expiryTime: _expiryTimeController.text, // "YYYY-MM-DD HH:mm"
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
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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

// View Donations Screen (API-backed)
class ViewDonationsScreen extends StatefulWidget {
  ViewDonationsScreen({super.key});

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen> {
  List<DonationModel> donations = [];
  bool isLoading = true;
  String? error;

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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Donations')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentDonations = donations.where((d) => d.status != 'Delivered' && d.status != 'Expired').toList();
    final pastDonations = donations.where((d) => d.status == 'Delivered' || d.status == 'Expired').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Donations'),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
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
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentDonations.length,
                    itemBuilder: (context, index) => _buildDonationListItem(context, currentDonations[index]),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pastDonations.length,
                    itemBuilder: (context, index) => _buildDonationListItem(context, pastDonations[index]),
                  ),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.backgroundLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subtleLight,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'My Donations'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Track'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/donor_dashboard');
            if (index == 2) Navigator.pushNamed(context, '/track_request_status');
            if (index == 3) Navigator.pushNamed(context, '/profile_donor');
          },
        ),
      ),
    );
  }

  Widget _buildDonationListItem(BuildContext context, DonationModel donation) {
    Color statusColor;
    Color statusBgColor;
    switch (donation.status) {
      case 'Pending':
        statusColor = Colors.orange.shade800;
        statusBgColor = Colors.orange.shade100;
        break;
      case 'Verified':
        statusColor = Colors.blue.shade800;
        statusBgColor = Colors.blue.shade100;
        break;
      case 'Allocated':
        statusColor = Colors.purple.shade800;
        statusBgColor = Colors.purple.shade100;
        break;
      case 'Delivered':
        statusColor = Colors.green.shade800;
        statusBgColor = Colors.green.shade100;
        break;
      case 'Expired':
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade100;
        break;
      default:
        statusColor = AppColors.foregroundLight;
        statusBgColor = AppColors.backgroundLight;
    }

    return Card(
      elevation: 0,
      color: AppColors.cardLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AppColors.iconBackgroundLight,
                child: const Center(child: Icon(Icons.fastfood, size: 30, color: AppColors.subtleLight)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.foodType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Quantity: ${donation.quantity}\nPickup: ${donation.pickupAddress}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight),
                    maxLines: 2,
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
                Text(donation.createdAt.split('T').first, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Create Request Screen
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
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

// Track Request Status Screen (API-backed)
class TrackRequestStatusScreen extends StatefulWidget {
  const TrackRequestStatusScreen({super.key});

  @override
  State<TrackRequestStatusScreen> createState() => _TrackRequestStatusScreenState();
}

class _TrackRequestStatusScreenState extends State<TrackRequestStatusScreen> {
  List<RequestModel> requests = [];
  bool isLoading = true;
  String? error;

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
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
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
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/receiver_dashboard');
            if (index == 3) Navigator.pushNamed(context, '/profile_receiver');
          },
        ),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, List<RequestModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No items'));
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

// --- C. NGO Flow (left mostly as UI with placeholders where backend methods may differ) ---

class VerifyDonationsScreenNGO extends StatelessWidget {
  const VerifyDonationsScreenNGO({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with ApiService.getPendingDonationsForNGO() when available
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Verification'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Text('Connect to NGO verification API to list pending donations here.'),
      ),
    );
  }
}

class AllocateRequestsScreenNGO extends StatelessWidget {
  const AllocateRequestsScreenNGO({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with ApiService.getRequestsForAllocation() and allocation actions
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Donation'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Text('Connect to allocation API to match and allocate donations to requests.'),
      ),
    );
  }
}

class TransactionsScreenNGO extends StatelessWidget {
  const TransactionsScreenNGO({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with ApiService.getNGOTransactions()
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(child: Text('Connect to transactions API.')),
    );
  }
}

class FeedbackRatingsScreenNGO extends StatelessWidget {
  const FeedbackRatingsScreenNGO({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with ApiService.getFeedback()
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(child: Text('Connect to feedback API.')),
    );
  }
}

// --- V. General & Profile Management ---

// Donor Profile Screen
class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  UserModel? profile;
  bool isLoading = true;

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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://via.placeholder.com/150?text=Donor+Avatar'),
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
                  _buildProfileInfoRow(context, 'Email', profile!.email),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  _buildProfileInfoRow(context, 'Address', profile!.address ?? 'Not provided'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/donor_dashboard');
          if (index == 1) Navigator.pushNamed(context, '/view_donations');
          if (index == 2) Navigator.pushNamed(context, '/track_request_status');
        },
      ),
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleLight)),
        ],
      ),
    );
  }
}

// NGO Profile Screen
class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  UserModel? profile;
  bool isLoading = true;

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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://via.placeholder.com/150?text=NGO+Avatar'),
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
                Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/ngo_dashboard');
          if (index == 1) Navigator.pushNamed(context, '/verify_donations_ngo');
          if (index == 2) Navigator.pushNamed(context, '/allocate_requests_ngo');
          if (index == 3) Navigator.pushNamed(context, '/transactions_ngo');
        },
      ),
    );
  }
}

// Receiver Profile Screen
class ReceiverProfileScreen extends StatefulWidget {
  const ReceiverProfileScreen({super.key});

  @override
  State<ReceiverProfileScreen> createState() => _ReceiverProfileScreenState();
}

class _ReceiverProfileScreenState extends State<ReceiverProfileScreen> {
  UserModel? profile;
  bool isLoading = true;

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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: const NetworkImage('https://via.placeholder.com/150?text=Receiver+Avatar'),
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
                  _buildProfileNavigation(context, 'Personal Information', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  _buildProfileNavigation(context, 'Request History', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.backgroundLight),
                  _buildProfileNavigation(context, 'Delivery Preferences', () {}),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await context.read<UserState>().logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleLight,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/receiver_dashboard');
          if (index == 2) Navigator.pushNamed(context, '/track_request_status');
        },
      ),
    );
  }

  Widget _buildProfileNavigation(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
      onTap: onTap,
    );
  }
}

// General Settings Screen
class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildSettingsNavigation(context, 'App Preferences', () => Navigator.pushNamed(context, '/app_preferences')),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildSettingsNavigation(context, 'Notifications', () => Navigator.pushNamed(context, '/notification_settings')),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildSettingsNavigation(context, 'Privacy Settings', () => Navigator.pushNamed(context, '/privacy_settings')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Help & Support', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildSettingsNavigation(context, 'FAQs', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildSettingsNavigation(context, 'Contact Us', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildSettingsNavigation(context, 'User Guide', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsNavigation(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
      onTap: onTap,
    );
  }
}

// App Preferences Screen
class AppPreferencesScreen extends StatelessWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPreferenceNavigation(context, 'Language', 'English'),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildPreferenceNavigation(context, 'Theme', 'System Default'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Data', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: _buildPreferenceNavigation(context, 'Data Usage', 'Standard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceNavigation(BuildContext context, String title, String currentValue) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentValue, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleLight)),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.subtleLight),
        ],
      ),
      onTap: () {},
    );
  }
}

// Notification Settings Screen
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newDonations = true;
  bool _requestUpdates = false;
  bool _messages = true;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildNotificationToggle(context, 'New Donations', 'Get notified when new donations are available', _newDonations, (value) => setState(() => _newDonations = value)),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildNotificationToggle(context, 'Request Updates', 'Receive updates on your donation requests', _requestUpdates, (value) => setState(() => _requestUpdates = value)),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildNotificationToggle(context, 'Messages', 'Get notified about new messages', _messages, (value) => setState(() => _messages = value)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Sound', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text('Notification Sound', style: Theme.of(context).textTheme.titleMedium),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Default', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleLight)),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.subtleLight),
                  ],
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 32),
            Text('Quiet Hours', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: _buildNotificationToggle(context, 'Quiet Hours', 'Mute notifications during specific hours', _quietHours, (value) => setState(() => _quietHours = value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// Privacy Settings Screen
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataSharing = true;
  bool _locationServices = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Sharing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPrivacyToggle(context, 'Data Sharing', 'Allow FoodLink to share your data with trusted partners.', _dataSharing, (value) => setState(() => _dataSharing = value)),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildPrivacyToggle(context, 'Location Services', 'Enable location services to find nearby donors and recipients.', _locationServices, (value) => setState(() => _locationServices = value)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Personal Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildPrivacyNavigation(context, 'Profile Visibility', 'Control who can see your profile information.'),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildPrivacyNavigation(context, 'Donation/Request Visibility', 'Manage visibility of your donations and requests.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNavigation(BuildContext context, String title, String subtitle) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleLight)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
      onTap: () {},
    );
  }
}

// Account Settings Screen
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildAccountNavigation(context, 'Change Password', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildAccountNavigation(context, 'Delete Account', () {}, isDestructive: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Social Accounts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildAccountNavigation(context, 'Link Facebook', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildAccountNavigation(context, 'Link Instagram', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNavigation(BuildContext context, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDestructive ? Colors.red : AppColors.foregroundLight,
            ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
      onTap: onTap,
    );
  }
}

// About Us Screen
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Mission', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'FoodLink\'s mission is to connect donors, NGOs, and receivers to reduce food waste and distribute surplus food effectively.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Our Vision', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'A world where surplus food is efficiently distributed to those in need.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Our Team', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'A dedicated team passionate about sustainability and social impact.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Legal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildLegalLink(context, 'Terms of Service', () {}),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  _buildLegalLink(context, 'Privacy Policy', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleLight),
      onTap: onTap,
    );
  }
}
