class RequestModel {
  final int id;
  final int receiverId;
  final String foodType;
  final String quantity;
  final String address;
  final String? notes;
  final String status;  // e.g., 'Requested', 'Matched', 'Fulfilled', 'Cancelled'
  final String createdAt;
  
  // Additional database fields
  final String? receiverName;
  final String? receiverPhone;
  final String? receiverEmail;
  final double? latitude;
  final double? longitude;
  final String urgencyLevel;  // 'Low', 'Medium', 'High', 'Critical'
  final int? familySize;
  final String? dietaryRestrictions;
  final bool needsHalal;
  final bool needsVegan;
  final bool needsGlutenFree;
  final DateTime? neededBy;
  final String? preferredPickupTime;
  final int? matchedDonationId;
  final DateTime? matchedAt;
  final int? matchedBy;  // NGO user ID who made the match
  final DateTime? fulfilledAt;
  final String? cancellationReason;
  final DateTime? lastUpdated;
  final String? specialInstructions;
  final double? maxTravelDistance;  // km
  final String? transportationMethod;
  final int? viewCount;
  final String requestSource;  // 'Mobile App', 'Website', 'Phone Call', 'Walk-in'

  RequestModel({
    required this.id,
    required this.receiverId,
    required this.foodType,
    required this.quantity,
    required this.address,
    this.notes,
    required this.status,
    required this.createdAt,
    // Additional fields
    this.receiverName,
    this.receiverPhone,
    this.receiverEmail,
    this.latitude,
    this.longitude,
    this.urgencyLevel = 'Medium',
    this.familySize,
    this.dietaryRestrictions,
    this.needsHalal = false,
    this.needsVegan = false,
    this.needsGlutenFree = false,
    this.neededBy,
    this.preferredPickupTime,
    this.matchedDonationId,
    this.matchedAt,
    this.matchedBy,
    this.fulfilledAt,
    this.cancellationReason,
    this.lastUpdated,
    this.specialInstructions,
    this.maxTravelDistance,
    this.transportationMethod,
    this.viewCount = 0,
    this.requestSource = 'Mobile App',
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['request_id'] ?? json['id'],
      receiverId: json['user_id'] ?? json['receiverId'] ?? 0,
      foodType: json['food_type'] ?? json['foodType'] ?? '',
      quantity: json['quantity'] ?? '',
      address: json['delivery_address'] ?? json['address'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'Requested',
      createdAt: json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      // Additional fields
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      receiverEmail: json['receiver_email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      urgencyLevel: json['urgency_level'] ?? 'Medium',
      familySize: json['family_size'],
      dietaryRestrictions: json['dietary_restrictions'],
      needsHalal: json['needs_halal'] ?? false,
      needsVegan: json['needs_vegan'] ?? false,
      needsGlutenFree: json['needs_gluten_free'] ?? false,
      neededBy: json['needed_by'] != null ? DateTime.tryParse(json['needed_by']) : null,
      preferredPickupTime: json['preferred_pickup_time'],
      matchedDonationId: json['matched_donation_id'],
      matchedAt: json['matched_at'] != null ? DateTime.tryParse(json['matched_at']) : null,
      matchedBy: json['matched_by'],
      fulfilledAt: json['fulfilled_at'] != null ? DateTime.tryParse(json['fulfilled_at']) : null,
      cancellationReason: json['cancellation_reason'],
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
      specialInstructions: json['special_instructions'],
      maxTravelDistance: json['max_travel_distance']?.toDouble(),
      transportationMethod: json['transportation_method'],
      viewCount: json['view_count'] ?? 0,
      requestSource: json['request_source'] ?? 'Mobile App',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'receiverId': receiverId,
    'foodType': foodType,
    'quantity': quantity,
    'address': address,
    'notes': notes,
    'status': status,
    'createdAt': createdAt,
    // Additional fields
    'receiverName': receiverName,
    'receiverPhone': receiverPhone,
    'receiverEmail': receiverEmail,
    'latitude': latitude,
    'longitude': longitude,
    'urgencyLevel': urgencyLevel,
    'familySize': familySize,
    'dietaryRestrictions': dietaryRestrictions,
    'needsHalal': needsHalal,
    'needsVegan': needsVegan,
    'needsGlutenFree': needsGlutenFree,
    'neededBy': neededBy?.toIso8601String(),
    'preferredPickupTime': preferredPickupTime,
    'matchedDonationId': matchedDonationId,
    'matchedAt': matchedAt?.toIso8601String(),
    'matchedBy': matchedBy,
    'fulfilledAt': fulfilledAt?.toIso8601String(),
    'cancellationReason': cancellationReason,
    'lastUpdated': lastUpdated?.toIso8601String(),
    'specialInstructions': specialInstructions,
    'maxTravelDistance': maxTravelDistance,
    'transportationMethod': transportationMethod,
    'viewCount': viewCount,
    'requestSource': requestSource,
  };
}