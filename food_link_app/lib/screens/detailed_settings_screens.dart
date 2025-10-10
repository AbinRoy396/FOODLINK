import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- Detailed Settings Screens ---

// --- Account Settings Screen ---
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Account Settings',
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
              'Personal Information',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'your@email.com',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1 (555) 123-4567',
                          filled: true,
                          fillColor: AppColors.inputLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _loading = true);
                            await Future.delayed(const Duration(seconds: 1));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully!')),
                              );
                              Navigator.pop(context);
                            }
                            setState(() => _loading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Danger Zone
            Text(
              'Account Actions',
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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock_reset, color: Colors.orange),
                    title: Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password change coming soon')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      'Delete Account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently delete your account and data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requires backend integration')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

// --- Notification Settings Screen ---
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newDonations = true;
  bool _requestUpdates = true;
  bool _allocationNotifications = true;
  bool _systemUpdates = false;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Notifications',
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
              'Push Notifications',
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'New Donations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Get notified when new food donations are available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _newDonations,
                    onChanged: (value) => setState(() => _newDonations = value),
                    secondary: Icon(Icons.card_giftcard, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'Request Updates',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Notifications about your food requests',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _requestUpdates,
                    onChanged: (value) => setState(() => _requestUpdates = value),
                    secondary: Icon(Icons.update, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'Allocation Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'When NGOs allocate food to your requests',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _allocationNotifications,
                    onChanged: (value) => setState(() => _allocationNotifications = value),
                    secondary: Icon(Icons.local_shipping, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'System Updates',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'App updates and maintenance notifications',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _systemUpdates,
                    onChanged: (value) => setState(() => _systemUpdates = value),
                    secondary: Icon(Icons.system_update, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Email Notifications',
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Email Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Receive email updates about your activity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _emailNotifications,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                    secondary: Icon(Icons.email, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings saved!')),
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
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Privacy Settings Screen ---
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationServices = true;
  bool _analytics = true;
  bool _crashReporting = true;
  bool _showProfilePublic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Privacy',
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
              'Privacy Settings',
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Location Services',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Allow access to location for better food matching',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _locationServices,
                    onChanged: (value) => setState(() => _locationServices = value),
                    secondary: Icon(Icons.location_on, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'Analytics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Help us improve by sharing usage data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _analytics,
                    onChanged: (value) => setState(() => _analytics = value),
                    secondary: Icon(Icons.analytics, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'Crash Reporting',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Automatically report crashes to improve stability',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _crashReporting,
                    onChanged: (value) => setState(() => _crashReporting = value),
                    secondary: Icon(Icons.bug_report, color: AppColors.primary),
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  SwitchListTile(
                    title: Text(
                      'Public Profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Make your profile visible to other users',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    value: _showProfilePublic,
                    onChanged: (value) => setState(() => _showProfilePublic = value),
                    secondary: Icon(Icons.visibility, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Data Management',
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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.download, color: AppColors.primary),
                    title: Text(
                      'Export Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Download your personal data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data export requires backend integration')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.delete_sweep, color: Colors.red),
                    title: Text(
                      'Delete All Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently delete all your data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showDeleteDataDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings saved!')),
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
              child: const Text('Save Privacy Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text('This will permanently delete all your donations, requests, and profile data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data deletion requires backend integration')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
  }
}
