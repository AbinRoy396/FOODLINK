class AnalyticsModel {
  final int id;
  final String eventType;  // 'donation_created', 'request_fulfilled', 'user_registered', etc.
  final int? userId;
  final int? donationId;
  final int? requestId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? sessionId;
  final String? deviceInfo;
  final String? location;

  AnalyticsModel({
    required this.id,
    required this.eventType,
    this.userId,
    this.donationId,
    this.requestId,
    this.metadata,
    required this.timestamp,
    this.sessionId,
    this.deviceInfo,
    this.location,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['id'],
      eventType: json['event_type'],
      userId: json['user_id'],
      donationId: json['donation_id'],
      requestId: json['request_id'],
      metadata: json['metadata'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['session_id'],
      deviceInfo: json['device_info'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventType': eventType,
    'userId': userId,
    'donationId': donationId,
    'requestId': requestId,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'deviceInfo': deviceInfo,
    'location': location,
  };
}

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;  // 'donation_match', 'pickup_reminder', 'status_update', etc.
  final bool isRead;
  final Map<String, dynamic>? actionData;
  final DateTime createdAt;
  final DateTime? readAt;
  final String priority;  // 'Low', 'Medium', 'High'

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.actionData,
    required this.createdAt,
    this.readAt,
    this.priority = 'Medium',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] ?? false,
      actionData: json['action_data'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      priority: json['priority'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'actionData': actionData,
    'createdAt': createdAt.toIso8601String(),
    'readAt': readAt?.toIso8601String(),
    'priority': priority,
  };
}

class FeedbackModel {
  final int id;
  final int userId;
  final String userType;  // 'Donor', 'Receiver', 'NGO'
  final int? donationId;
  final int? requestId;
  final int rating;  // 1-5 stars
  final String? comment;
  final String category;  // 'Food Quality', 'Pickup Experience', 'App Usability', etc.
  final DateTime createdAt;
  final bool isAnonymous;
  final String? improvementSuggestions;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userType,
    this.donationId,
    this.requestId,
    required this.rating,
    this.comment,
    required this.category,
    required this.createdAt,
    this.isAnonymous = false,
    this.improvementSuggestions,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['user_id'],
      userType: json['user_type'],
      donationId: json['donation_id'],
      requestId: json['request_id'],
      rating: json['rating'],
      comment: json['comment'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      isAnonymous: json['is_anonymous'] ?? false,
      improvementSuggestions: json['improvement_suggestions'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userType': userType,
    'donationId': donationId,
    'requestId': requestId,
    'rating': rating,
    'comment': comment,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'isAnonymous': isAnonymous,
    'improvementSuggestions': improvementSuggestions,
  };
}
