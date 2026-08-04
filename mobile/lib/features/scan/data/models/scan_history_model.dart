class ScanHistoryModel {
  final int id;
  final String prediction;
  final num confidence;
  final String severity;
  final String crop;
  final String imageUrl;
  final String? heatmapUrl;
  final num? infectionPercentage;
  final String timestamp;

  const ScanHistoryModel({
    required this.id,
    required this.prediction,
    required this.confidence,
    required this.severity,
    required this.crop,
    required this.imageUrl,
    this.heatmapUrl,
    this.infectionPercentage,
    required this.timestamp,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] ?? 0,
      prediction: json['prediction'] ?? '',
      confidence: json['confidence'] ?? 0,
      severity: json['severity'] ?? '',
      crop: json['crop_type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      heatmapUrl: json['heatmap_url'],
      infectionPercentage: json['infected_area_percent'],
      timestamp: json['created_at'] ?? '',
    );
  }
}
