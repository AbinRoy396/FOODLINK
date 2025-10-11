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
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'],
      donorId: json['donorId'],
      donorName: json['donorName'] ?? 'Unknown Donor',
      foodType: json['foodType'],
      category: json['category'] ?? 'Other',
      quantity: json['quantity'],
      description: json['description'] ?? '',
      expiryDate: json['expiryDate'] ?? json['expiryTime'] ?? '',
      pickupAddress: json['pickupAddress'],
      status: json['status'],
      createdAt: json['createdAt'] is String 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : json['createdAt'] ?? DateTime.now(),
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
  };
}