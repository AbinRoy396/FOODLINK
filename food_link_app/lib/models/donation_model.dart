class DonationModel {
  final int id;
  final int donorId;
  final String donorName;
  final String foodType;
  final String category;
  final String quantity;
  final String description;
  final String expiryDate;
  final String pickupAddress;
  final String status;  // e.g., 'Pending', 'Verified', 'Allocated', 'Delivered', 'Expired'
  final DateTime createdAt;
  
  // Additional database fields
  final String? donorPhone;
  final String? donorEmail;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls;
  final String? allergenInfo;
  final String? storageInstructions;
  final int? servingSize;
  final String? nutritionalInfo;
  final bool isHalal;
  final bool isVegan;
  final bool isGlutenFree;
  final String priority;  // 'Low', 'Medium', 'High', 'Urgent'
  final DateTime? pickupTimeStart;
  final DateTime? pickupTimeEnd;
  final DateTime? lastUpdated;
  final int? verifiedBy;  // NGO user ID who verified
  final DateTime? verifiedAt;
  final int? allocatedTo;  // Receiver ID
  final DateTime? allocatedAt;
  final String? rejectionReason;
  final double? estimatedValue;  // Monetary value estimate
  final String? donationSource;  // 'Restaurant', 'Individual', 'Event', 'Grocery Store'
  final int? viewCount;
  final int? requestCount;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.foodType,
    required this.category,
    required this.quantity,
    required this.description,
    required this.expiryDate,
    required this.pickupAddress,
    required this.status,
    required this.createdAt,
    // Additional fields
    this.donorPhone,
    this.donorEmail,
    this.latitude,
    this.longitude,
    this.imageUrls,
    this.allergenInfo,
    this.storageInstructions,
    this.servingSize,
    this.nutritionalInfo,
    this.isHalal = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.priority = 'Medium',
    this.pickupTimeStart,
    this.pickupTimeEnd,
    this.lastUpdated,
    this.verifiedBy,
    this.verifiedAt,
    this.allocatedTo,
    this.allocatedAt,
    this.rejectionReason,
    this.estimatedValue,
    this.donationSource,
    this.viewCount = 0,
    this.requestCount = 0,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['donation_id'] ?? json['id'],
      donorId: json['user_id'] ?? json['donorId'] ?? 0,
      donorName: json['donorName'] ?? json['donor_name'] ?? 'Unknown Donor',
      foodType: json['food_type'] ?? json['foodType'] ?? '',
      category: json['category'] ?? 'Other',
      quantity: json['quantity'] ?? '',
      description: json['description'] ?? '',
      expiryDate: json['expiry_time'] ?? json['expiryTime'] ?? json['expiryDate'] ?? '',
      pickupAddress: json['pickup_address'] ?? json['pickupAddress'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'] != null
          ? (json['created_at'] is String 
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now())
          : (json['createdAt'] is String 
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      // Additional fields
      donorPhone: json['donor_phone'],
      donorEmail: json['donor_email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : null,
      allergenInfo: json['allergen_info'],
      storageInstructions: json['storage_instructions'],
      servingSize: json['serving_size'],
      nutritionalInfo: json['nutritional_info'],
      isHalal: json['is_halal'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      priority: json['priority'] ?? 'Medium',
      pickupTimeStart: json['pickup_time_start'] != null ? DateTime.tryParse(json['pickup_time_start']) : null,
      pickupTimeEnd: json['pickup_time_end'] != null ? DateTime.tryParse(json['pickup_time_end']) : null,
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at']) : null,
      allocatedTo: json['allocated_to'],
      allocatedAt: json['allocated_at'] != null ? DateTime.tryParse(json['allocated_at']) : null,
      rejectionReason: json['rejection_reason'],
      estimatedValue: json['estimated_value']?.toDouble(),
      donationSource: json['donation_source'],
      viewCount: json['view_count'] ?? 0,
      requestCount: json['request_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'donorId': donorId,
    'donorName': donorName,
    'foodType': foodType,
    'category': category,
    'quantity': quantity,
    'description': description,
    'expiryDate': expiryDate,
    'pickupAddress': pickupAddress,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    // Additional fields
    'donorPhone': donorPhone,
    'donorEmail': donorEmail,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrls': imageUrls,
    'allergenInfo': allergenInfo,
    'storageInstructions': storageInstructions,
    'servingSize': servingSize,
    'nutritionalInfo': nutritionalInfo,
    'isHalal': isHalal,
    'isVegan': isVegan,
    'isGlutenFree': isGlutenFree,
    'priority': priority,
    'pickupTimeStart': pickupTimeStart?.toIso8601String(),
    'pickupTimeEnd': pickupTimeEnd?.toIso8601String(),
    'lastUpdated': lastUpdated?.toIso8601String(),
    'verifiedBy': verifiedBy,
    'verifiedAt': verifiedAt?.toIso8601String(),
    'allocatedTo': allocatedTo,
    'allocatedAt': allocatedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'estimatedValue': estimatedValue,
    'donationSource': donationSource,
    'viewCount': viewCount,
    'requestCount': requestCount,
  };
}