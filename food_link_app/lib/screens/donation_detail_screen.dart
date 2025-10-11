import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/donation_model.dart';
import '../utils/app_colors.dart';

class DonationDetailScreen extends StatelessWidget {
  final DonationModel donation;

  const DonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Check out this food donation!\n\n'
                '🍽️ Food Type: ${donation.foodType}\n'
                '📦 Quantity: ${donation.quantity}\n'
                '📍 Pickup: ${donation.pickupAddress}\n'
                '⏰ Expires: ${donation.expiryDate}\n'
                '✅ Status: ${donation.status}\n\n'
                'Help reduce food waste with FoodLink!',
                subject: 'Food Donation - ${donation.foodType}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food icon placeholder (or image if available)
            Hero(
              tag: 'donation_${donation.id}',
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fastfood, size: 80, color: AppColors.subtleLight),
              ),
            ),
            const SizedBox(height: 24),
            
            // Status badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(donation.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  donation.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(donation.status),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Details
            _DetailRow(
              icon: Icons.restaurant,
              label: 'Food Type',
              value: donation.foodType,
            ),
            _DetailRow(
              icon: Icons.scale,
              label: 'Quantity',
              value: donation.quantity,
            ),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Pickup Address',
              value: donation.pickupAddress,
            ),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Expiry Time',
              value: donation.expiryDate,
            ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Created',
              value: '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.statusPending;
      case 'Verified':
        return AppColors.statusVerified;
      case 'Allocated':
        return AppColors.statusAllocated;
      case 'Delivered':
        return AppColors.statusDelivered;
      case 'Expired':
        return AppColors.statusExpired;
      default:
        return AppColors.foregroundLight;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iconBackgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.subtleLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
