class OrganizationModel {
  final int id;
  final String name;
  final String type;  // 'NGO', 'Restaurant', 'Grocery Store', 'Food Bank', etc.
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? registrationNumber;
  final bool isVerified;
  final DateTime? verifiedAt;
  final int? verifiedBy;
  final String status;  // 'Active', 'Inactive', 'Suspended'
  final List<String>? serviceAreas;  // Geographic areas they serve
  final Map<String, dynamic>? operatingHours;
  final String? logoUrl;
  final List<String>? certifications;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final int? totalDonationsHandled;
  final int? totalRequestsFulfilled;
  final double? averageRating;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.registrationNumber,
    this.isVerified = false,
    this.verifiedAt,
    this.verifiedBy,
    this.status = 'Active',
    this.serviceAreas,
    this.operatingHours,
    this.logoUrl,
    this.certifications,
    required this.createdAt,
    this.lastUpdated,
    this.totalDonationsHandled = 0,
    this.totalRequestsFulfilled = 0,
    this.averageRating,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      registrationNumber: json['registration_number'],
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at']) : null,
      verifiedBy: json['verified_by'],
      status: json['status'] ?? 'Active',
      serviceAreas: json['service_areas'] != null ? List<String>.from(json['service_areas']) : null,
      operatingHours: json['operating_hours'],
      logoUrl: json['logo_url'],
      certifications: json['certifications'] != null ? List<String>.from(json['certifications']) : null,
      createdAt: DateTime.parse(json['created_at']),
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated']) : null,
      totalDonationsHandled: json['total_donations_handled'] ?? 0,
      totalRequestsFulfilled: json['total_requests_fulfilled'] ?? 0,
      averageRating: json['average_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'description': description,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'phone': phone,
    'email': email,
    'website': website,
    'registrationNumber': registrationNumber,
    'isVerified': isVerified,
    'verifiedAt': verifiedAt?.toIso8601String(),
    'verifiedBy': verifiedBy,
    'status': status,
    'serviceAreas': serviceAreas,
    'operatingHours': operatingHours,
    'logoUrl': logoUrl,
    'certifications': certifications,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated?.toIso8601String(),
    'totalDonationsHandled': totalDonationsHandled,
    'totalRequestsFulfilled': totalRequestsFulfilled,
    'averageRating': averageRating,
  };
}

class InventoryModel {
  final int id;
  final int organizationId;
  final String itemName;
  final String category;
  final int quantity;
  final String unit;  // 'kg', 'pieces', 'liters', etc.
  final DateTime? expiryDate;
  final String condition;  // 'Fresh', 'Good', 'Near Expiry'
  final String storageLocation;
  final double? temperature;  // Storage temperature
  final String? batchNumber;
  final DateTime receivedAt;
  final int? receivedFromDonationId;
  final bool isAllocated;
  final int? allocatedToRequestId;
  final DateTime? allocatedAt;
  final String? notes;

  InventoryModel({
    required this.id,
    required this.organizationId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.condition = 'Good',
    required this.storageLocation,
    this.temperature,
    this.batchNumber,
    required this.receivedAt,
    this.receivedFromDonationId,
    this.isAllocated = false,
    this.allocatedToRequestId,
    this.allocatedAt,
    this.notes,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      organizationId: json['organization_id'],
      itemName: json['item_name'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      condition: json['condition'] ?? 'Good',
      storageLocation: json['storage_location'],
      temperature: json['temperature']?.toDouble(),
      batchNumber: json['batch_number'],
      receivedAt: DateTime.parse(json['received_at']),
      receivedFromDonationId: json['received_from_donation_id'],
      isAllocated: json['is_allocated'] ?? false,
      allocatedToRequestId: json['allocated_to_request_id'],
      allocatedAt: json['allocated_at'] != null ? DateTime.parse(json['allocated_at']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'itemName': itemName,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'expiryDate': expiryDate?.toIso8601String(),
    'condition': condition,
    'storageLocation': storageLocation,
    'temperature': temperature,
    'batchNumber': batchNumber,
    'receivedAt': receivedAt.toIso8601String(),
    'receivedFromDonationId': receivedFromDonationId,
    'isAllocated': isAllocated,
    'allocatedToRequestId': allocatedToRequestId,
    'allocatedAt': allocatedAt?.toIso8601String(),
    'notes': notes,
  };
}
