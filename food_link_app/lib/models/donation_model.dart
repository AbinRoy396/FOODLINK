class DonationModel {
  final int id;
  final int donorId;
  final String foodType;
  final String quantity;
  final String pickupAddress;
  final String expiryTime;
  final String status;  // e.g., 'Pending', 'Verified', 'Allocated', 'Delivered', 'Expired'
  final String createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.foodType,
    required this.quantity,
    required this.pickupAddress,
    required this.expiryTime,
    required this.status,
    required this.createdAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'],
      donorId: json['donorId'],
      foodType: json['foodType'],
      quantity: json['quantity'],
      pickupAddress: json['pickupAddress'],
      expiryTime: json['expiryTime'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'donorId': donorId,
    'foodType': foodType,
    'quantity': quantity,
    'pickupAddress': pickupAddress,
    'expiryTime': expiryTime,
    'status': status,
    'createdAt': createdAt,
  };
}