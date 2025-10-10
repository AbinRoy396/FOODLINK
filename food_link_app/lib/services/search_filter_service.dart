import '../models/donation_model.dart';
import '../models/sort_option.dart';

class SearchFilterService {
  /// Search donations by food type, address, or quantity
  static List<DonationModel> searchDonations(
    List<DonationModel> donations,
    String query,
  ) {
    if (query.isEmpty) return donations;

    final lowerQuery = query.toLowerCase();
    return donations.where((donation) {
      return donation.foodType.toLowerCase().contains(lowerQuery) ||
          donation.pickupAddress.toLowerCase().contains(lowerQuery) ||
          donation.quantity.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter donations by status
  static List<DonationModel> filterByStatus(
    List<DonationModel> donations,
    List<String> statuses,
  ) {
    if (statuses.isEmpty) return donations;
    return donations.where((d) => statuses.contains(d.status)).toList();
  }

  /// Filter donations by date range
  static List<DonationModel> filterByDateRange(
    List<DonationModel> donations,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return donations;

    return donations.where((donation) {
      try {
        final donationDate = DateTime.parse(donation.createdAt);
        if (startDate != null && donationDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && donationDate.isAfter(endDate)) {
          return false;
        }
        return true;
      } catch (e) {
        return true; // Include if date parsing fails
      }
    }).toList();
  }

  /// Sort donations
  static List<DonationModel> sortDonations(
    List<DonationModel> donations,
    SortOption sortBy,
  ) {
    final sorted = List<DonationModel>.from(donations);
    
    switch (sortBy) {
      case SortOption.dateNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateOldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.foodType:
        sorted.sort((a, b) => a.foodType.compareTo(b.foodType));
        break;
      case SortOption.status:
        sorted.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
    
    return sorted;
  }

  /// Apply all filters and search
  static List<DonationModel> applyFilters({
    required List<DonationModel> donations,
    String? searchQuery,
    List<String>? statusFilters,
    DateTime? startDate,
    DateTime? endDate,
    SortOption? sortBy,
  }) {
    var result = donations;

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = searchDonations(result, searchQuery);
    }

    // Apply status filter
    if (statusFilters != null && statusFilters.isNotEmpty) {
      result = filterByStatus(result, statusFilters);
    }

    // Apply date range filter
    if (startDate != null || endDate != null) {
      result = filterByDateRange(result, startDate, endDate);
    }

    // Apply sorting
    if (sortBy != null) {
      result = sortDonations(result, sortBy);
    }

    return result;
  }
}
