class QuickTipModel {
  final int id;
  final String title;
  final String category;
  final String? crop; // Derived or mapped from category
  final String description; // maps to content
  final String? detailedContent; // maps to detailed_content
  final String author;
  final String readTime;
  final String? icon;
  final String priority;
  final List<String> tags;

  const QuickTipModel({
    required this.id,
    required this.title,
    required this.category,
    this.crop,
    required this.description,
    this.detailedContent,
    required this.author,
    required this.readTime,
    this.icon,
    this.priority = 'Normal',
    this.tags = const [],
  });

  QuickTipModel copyWith({
    int? id,
    String? title,
    String? category,
    String? crop,
    String? description,
    String? detailedContent,
    String? author,
    String? readTime,
    String? icon,
    String? priority,
    List<String>? tags,
  }) {
    return QuickTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      crop: crop ?? this.crop,
      description: description ?? this.description,
      detailedContent: detailedContent ?? this.detailedContent,
      author: author ?? this.author,
      readTime: readTime ?? this.readTime,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  factory QuickTipModel.fromJson(Map<String, dynamic> json) {
    return QuickTipModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      // The backend uses category for crop as well, so we can map it.
      crop: (json['category'] != null && json['category'] != 'General') 
          ? json['category'] 
          : null,
      description: json['content'] ?? '',
      detailedContent: json['detailed_content'],
      author: json['author'] ?? 'Anonymous',
      readTime: json['read_time'] ?? '1 min read',
      icon: null,
      priority: 'Normal', // Static for now as it's not in backend
      tags: [], // Static for now as it's not in backend
    );
  }
}
