class NotificationModel {
  final int id;
  final String title;
  final String message;
  final int? userId;
  final bool isRead;
  final String createdAt;
  
  // App-specific fallbacks since backend doesn't provide these
  final String type;
  final String priority;
  final int? scanId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.userId,
    required this.isRead,
    required this.createdAt,
    this.type = 'general',
    this.priority = 'normal',
    this.scanId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Attempt to parse scanId or type from message/title if possible
    final titleLower = (json['title'] as String?)?.toLowerCase() ?? '';
    final messageLower = (json['message'] as String?)?.toLowerCase() ?? '';
    
    String derivedType = 'general';
    if (titleLower.contains('scan') || messageLower.contains('scan')) {
      derivedType = 'scan';
    } else if (titleLower.contains('alert') || titleLower.contains('warning')) {
      derivedType = 'alert';
    }

    String derivedPriority = 'normal';
    if (titleLower.contains('critical') || titleLower.contains('urgent')) {
      derivedPriority = 'high';
    }

    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      userId: json['user_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      type: derivedType,
      priority: derivedPriority,
      scanId: null, // Backend doesn't support scan_id currently
    );
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    int? userId,
    bool? isRead,
    String? createdAt,
    String? type,
    String? priority,
    int? scanId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      scanId: scanId ?? this.scanId,
    );
  }
}
