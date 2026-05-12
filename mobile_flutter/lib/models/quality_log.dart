class QualityLog {
  final int id;
  final double weight;
  final double confidenceScore;
  final String status;
  final DateTime createdAt;

  QualityLog({
    required this.id,
    required this.weight,
    required this.confidenceScore,
    required this.status,
    required this.createdAt,
  });

  // Fungsi untuk mengubah JSON dari Laravel jadi Object Flutter
  factory QualityLog.fromJson(Map<String, dynamic> json) {
    return QualityLog(
      id: json['id'],
      weight: json['weight'].toDouble(),
      confidenceScore: json['confidence_score'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}