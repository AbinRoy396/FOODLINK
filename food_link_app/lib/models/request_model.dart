class RequestModel {
  final int id;
  final int receiverId;
  final String foodType;
  final String quantity;
  final String address;
  final String? notes;
  final String status;  // e.g., 'Requested', 'Matched', 'Fulfilled', 'Cancelled'
  final String createdAt;

  RequestModel({
    required this.id,
    required this.receiverId,
    required this.foodType,
    required this.quantity,
    required this.address,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      receiverId: json['receiverId'],
      foodType: json['foodType'],
      quantity: json['quantity'],
      address: json['address'],
      notes: json['notes'],
      status: json['status'],
      createdAt: json['createdAt'],
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
  };
}