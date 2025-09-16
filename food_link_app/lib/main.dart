// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const FoodLinkApp());
}

/* ===========================
   APP (Main)
   =========================== */
class FoodLinkApp extends StatelessWidget {
  const FoodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
      ],
      child: MaterialApp(
        title: 'FoodLink',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo.shade900,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo.shade900,
            foregroundColor: Colors.white,
            elevation: 6,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              elevation: 5,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/* ===========================
   MODELS
   =========================== */
enum UserType { donor, ngo }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final UserType type;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.type,
  });
}

enum DonationStatus { available, requested, allocated, delivered, cancelled }

class Donation {
  final String id;
  final String donorId;
  final String foodType;
  final String quantity;
  final String expiry;
  final String location;
  final String notes;
  DonationStatus status;
  String? ngoId;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.donorId,
    required this.foodType,
    required this.quantity,
    required this.expiry,
    required this.location,
    required this.notes,
    this.status = DonationStatus.available,
    this.ngoId,
    required this.createdAt,
  });

  String get statusText {
    switch (status) {
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.requested:
        return 'Requested';
      case DonationStatus.allocated:
        return 'Allocated';
      case DonationStatus.delivered:
        return 'Delivered';
      case DonationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case DonationStatus.available:
        return Colors.green.shade700;
      case DonationStatus.requested:
        return Colors.orange.shade700;
      case DonationStatus.allocated:
        return Colors.blue.shade700;
      case DonationStatus.delivered:
        return Colors.teal.shade700;
      case DonationStatus.cancelled:
        return Colors.red.shade700;
    }
  }
}

/* ===========================
   PROVIDERS
   =========================== */

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserType? _selectedRole;

  UserModel? get currentUser => _currentUser;
  UserType? get selectedRole => _selectedRole;
  bool get isAuthenticated => _currentUser != null;

  void setRole(UserType role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulate API/auth — here we create a demo user
    await Future.delayed(const Duration(milliseconds: 600));
    final role = _selectedRole ?? UserType.donor;
    _currentUser = UserModel(
      id: role == UserType.donor ? 'donor1' : 'ngo1',
      name: role == UserType.donor ? 'Demo Donor' : 'Demo NGO',
      email: email,
      phone: '+91 9876543210',
      address: 'Demo Address',
      city: 'Your City',
      type: role,
    );
    notifyListeners();
    return true;
  }

  Future<bool> register(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _selectedRole = null;
    notifyListeners();
  }
}

class DonationProvider with ChangeNotifier {
  final List<Donation> _donations = [
    Donation(
      id: 'd1',
      donorId: 'donor1',
      foodType: 'Mixed Veg Curry',
      quantity: '30 servings',
      expiry: '3 hours',
      location: 'Green Restaurant, MG Road',
      notes: 'Vegetarian, freshly cooked',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Donation(
      id: 'd2',
      donorId: 'donor2',
      foodType: 'Rice & Curry',
      quantity: '40 servings',
      expiry: '6 hours',
      location: 'Wedding Hall, East Fort',
      notes: 'Excess from ceremony',
      status: DonationStatus.requested,
      ngoId: 'ngo1',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<Donation> get all => List.unmodifiable(_donations);

  List<Donation> getAvailable() =>
      _donations.where((d) => d.status == DonationStatus.available).toList();

  List<Donation> getByDonor(String donorId) =>
      _donations.where((d) => d.donorId == donorId).toList();

  void add(Donation donation) {
    _donations.insert(0, donation);
    notifyListeners();
  }

  void request(String donationId, String ngoId) {
    final idx = _donations.indexWhere((d) => d.id == donationId);
    if (idx != -1) {
      _donations[idx].status = DonationStatus.requested;
      _donations[idx].ngoId = ngoId;
      notifyListeners();
    }
  }

  void updateStatus(String donationId, DonationStatus status) {
    final idx = _donations.indexWhere((d) => d.id == donationId);
    if (idx != -1) {
      _donations[idx].status = status;
      notifyListeners();
    }
  }
}

/* ===========================
   PREMIUM UI: SPLASH & WELCOME
   =========================== */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.restaurant_menu, size: 44, color: Colors.indigo.shade900),
                ),
              ),
              const SizedBox(height: 20),
              Text('FoodLink', style: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Connecting surplus food with those in need', textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.purple.shade700]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(Icons.restaurant_menu, size: 92, color: Colors.white70),
                const SizedBox(height: 18),
                Text('Welcome to FoodLink', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),
                Text('Help reduce food waste — donate or request surplus meals', textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade900,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.store),
                  label: Text('I am a Donor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    auth.setRole(UserType.donor);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade900,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.volunteer_activism),
                  label: Text('I am an NGO', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    auth.setRole(UserType.ngo);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
                  },
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   AUTH (Login / Register)
   =========================== */

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().selectedRole;
    final title = role == UserType.donor ? 'Donor' : 'NGO';

    return Scaffold(
      appBar: AppBar(title: Text('$title Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: const Text('Login'),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _doLogin() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    await auth.login(_email.text.trim(), _password.text.trim());
    setState(() => _loading = false);
    if (auth.isAuthenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) =>
          auth.currentUser!.type == UserType.donor ? const DonorDashboard() : const NGODashboard()
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().selectedRole;
    return Scaffold(
      appBar: AppBar(title: Text('${role == UserType.donor ? "Donor" : "NGO"} Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _doLogin,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Register instead')),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  void _doRegister() async {
    final auth = context.read<AuthProvider>();
    final role = auth.selectedRole ?? UserType.donor;

    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill name and email')));
      return;
    }

    setState(() => _loading = true);
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      type: role,
    );
    await auth.register(user);
    setState(() => _loading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => role == UserType.donor ? const DonorDashboard() : const NGODashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().selectedRole;
    return Scaffold(
      appBar: AppBar(title: Text('${role == UserType.donor ? "Donor" : "NGO"} Register')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name / Organization')),
            const SizedBox(height: 12),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _doRegister,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===========================
   DASHBOARDS
   =========================== */

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donations = context.watch<DonationProvider>().getByDonor(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        actions: [
          IconButton(onPressed: () {
            context.read<AuthProvider>().logout();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (r) => false);
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(auth.currentUser!.name.substring(0,1).toUpperCase())),
              title: Text('Hello, ${auth.currentUser!.name}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(auth.currentUser!.email),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDonationScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Add Donation'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: donations.isEmpty ? Center(child: Text('No donations yet', style: GoogleFonts.poppins())) : ListView.builder(
                itemCount: donations.length,
                itemBuilder: (context, i) {
                  final d = donations[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(d.foodType),
                      subtitle: Text('${d.quantity} • ${d.location}'),
                      trailing: Chip(label: Text(d.statusText), backgroundColor: d.statusColor.withOpacity(0.12)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NGODashboard extends StatelessWidget {
  const NGODashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final available = context.watch<DonationProvider>().getAvailable();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        actions: [
          IconButton(onPressed: () {
            context.read<AuthProvider>().logout();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (r) => false);
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(auth.currentUser!.name.substring(0,1).toUpperCase())),
              title: Text('Welcome, ${auth.currentUser!.name}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(auth.currentUser!.email),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: available.isEmpty ? Center(child: Text('No available donations', style: GoogleFonts.poppins())) : ListView.builder(
                itemCount: available.length,
                itemBuilder: (context, i) {
                  final d = available[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(d.foodType),
                      subtitle: Text('${d.quantity} • ${d.location}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.read<DonationProvider>().request(d.id, auth.currentUser!.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requested donation')));
                        },
                        child: const Text('Request'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===========================
   ADD DONATION SCREEN
   =========================== */

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});
  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}
class _AddDonationScreenState extends State<AddDonationScreen> {
  final _food = TextEditingController();
  final _qty = TextEditingController();
  final _expiry = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _food.dispose();
    _qty.dispose();
    _expiry.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() async {
    final auth = context.read<AuthProvider>();
    if (_food.text.trim().isEmpty || _qty.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter food and quantity')));
      return;
    }
    setState(() => _loading = true);
    final donation = Donation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donorId: auth.currentUser!.id,
      foodType: _food.text.trim(),
      quantity: _qty.text.trim(),
      expiry: _expiry.text.trim(),
      location: _location.text.trim(),
      notes: _notes.text.trim(),
      createdAt: DateTime.now(),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    context.read<DonationProvider>().add(donation);
    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Donation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _food, decoration: const InputDecoration(labelText: 'Food Type')),
            const SizedBox(height: 10),
            TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Quantity (e.g. 20 servings)')),
            const SizedBox(height: 10),
            TextField(controller: _expiry, decoration: const InputDecoration(labelText: 'Expiry (e.g. 4 hours)')),
            const SizedBox(height: 10),
            TextField(controller: _location, decoration: const InputDecoration(labelText: 'Pickup Location')),
            const SizedBox(height: 10),
            TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Donation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
