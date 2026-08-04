class ScanRecordModel {
  final int id;
  final String imageUrl;
  final String heatmapUrl;
  final String cropType;
  final String prediction;
  final double confidence;
  final String severity;
  final String createdAt;

  const ScanRecordModel({
    required this.id,
    required this.imageUrl,
    required this.heatmapUrl,
    required this.cropType,
    required this.prediction,
    required this.confidence,
    required this.severity,
    required this.createdAt,
  });

  factory ScanRecordModel.fromJson(Map<String, dynamic> json) {
    return ScanRecordModel(
      id: json['id'],
      imageUrl: json['image_url'] ?? '',
      heatmapUrl: json['heatmap_url'] ?? '',
      cropType: json['crop_type'] ?? '',
      prediction: json['prediction'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TipModel {
  final int id;
  final String title;
  final String category;
  final String readTime;
  final String content;
  final String? detailedContent;
  final String author;
  final bool isApproved;

  const TipModel({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.content,
    this.detailedContent,
    required this.author,
    required this.isApproved,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      readTime: json['read_time'] ?? '',
      content: json['content'] ?? '',
      detailedContent: json['detailed_content'],
      author: json['author'] ?? '',
      isApproved: json['is_approved'] ?? false,
    );
  }
}

class DashboardState {
  final bool isLoading;
  final String? error;
  final List<ScanRecordModel> recentScans;
  final List<TipModel> quickTips;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.recentScans = const [],
    this.quickTips = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    List<ScanRecordModel>? recentScans,
    List<TipModel>? quickTips,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      recentScans: recentScans ?? this.recentScans,
      quickTips: quickTips ?? this.quickTips,
    );
  }

  // Computed properties
  int get totalScans => recentScans.length;
  int get healthyPlants => recentScans.where((scan) => scan.prediction.toLowerCase() == 'healthy').length;
  int get diseasedPlants => totalScans - healthyPlants;
  double get accuracy {
    if (recentScans.isEmpty) return 0.0;
    final totalConfidence = recentScans.fold(0.0, (sum, scan) => sum + scan.confidence);
    return totalConfidence / recentScans.length;
  }
}
