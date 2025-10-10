import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../models/app_strings.dart';
import '../theme/app_colors.dart';

// --- Settings Screen ---
class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Settings',
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
              'General Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 24),

            // Theme Settings
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foregroundLight,
                          ),
                        ),
                        subtitle: Text(
                          'Switch between light and dark theme',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.subtleLight,
                          ),
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.language, color: AppColors.primary),
                    title: Text(
                      'Language',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'English (US)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language settings coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Settings
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline, color: AppColors.primary),
                    title: Text(
                      'Account Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Manage your account details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account settings coming soon')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: AppColors.primary),
                    title: Text(
                      'Notification Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Manage notification preferences',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings coming soon')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: Text(
                      'Privacy Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Control your privacy and data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy settings coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Information
            Card(
              elevation: 1,
              color: AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.primary),
                    title: Text(
                      'About FoodLink',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Learn about our mission and team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About us coming soon')),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, color: AppColors.borderLight),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: AppColors.primary),
                    title: Text(
                      'Help & Support',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    subtitle: Text(
                      'Get help and contact support',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleLight,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & support coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Version
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
