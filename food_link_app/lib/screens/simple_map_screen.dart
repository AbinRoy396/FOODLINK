import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../utils/app_colors.dart';

/// Simple map placeholder that doesn't require Google Maps API
class SimpleMapScreen extends StatelessWidget {
  final List<DonationModel>? donations;
  final String? title;

  const SimpleMapScreen({
    super.key,
    this.donations,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final donationCount = donations?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Map Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Map View',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
              const SizedBox(height: 16),

              // Donation Count
              if (donationCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$donationCount Donation${donationCount != 1 ? 's' : ''} Available',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Message
              Text(
                'Interactive map requires Google Maps API key',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.subtleLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'View donations in the list view for now',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.subtleLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Donation List
              if (donationCount > 0) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Available Locations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: donations!.length,
                    itemBuilder: (context, index) {
                      final donation = donations![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.location_on, color: AppColors.primary),
                          ),
                          title: Text(
                            donation.foodType,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            donation.pickupAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Chip(
                            label: Text(donation.quantity),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Help Button
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Enable Google Maps'),
                      content: const Text(
                        'To enable the interactive map:\n\n'
                        '1. Get a free Google Maps API key\n'
                        '2. Add it to AndroidManifest.xml\n'
                        '3. Rebuild the app\n\n'
                        'See GET_MAPS_API_KEY.md for instructions.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('How to enable maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
