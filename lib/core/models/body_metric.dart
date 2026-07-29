class BodyMetric {
  int? id;
  String date;
  double? weight;
  double? waist;
  String? frontPhotoPath;
  String? sidePhotoPath;
  String? notes;

  BodyMetric({
    this.id,
    required this.date,
    this.weight,
    this.waist,
    this.frontPhotoPath,
    this.sidePhotoPath,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'weight': weight,
        'waist': waist,
        'frontPhotoPath': frontPhotoPath,
        'sidePhotoPath': sidePhotoPath,
        'notes': notes,
      };

  factory BodyMetric.fromMap(Map<String, dynamic> m) => BodyMetric(
        id: m['id'],
        date: m['date'],
        weight: m['weight'] != null ? (m['weight'] as num).toDouble() : null,
        waist: m['waist'] != null ? (m['waist'] as num).toDouble() : null,
        frontPhotoPath: m['frontPhotoPath'],
        sidePhotoPath: m['sidePhotoPath'],
        notes: m['notes'],
      );
}
