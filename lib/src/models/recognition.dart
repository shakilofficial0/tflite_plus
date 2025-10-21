/// Represents a recognition result from image classification
class Recognition {
  /// The classification label
  final String? label;
  
  /// The confidence score (0.0 to 1.0)
  final double? confidence;
  
  /// The index of the recognized class
  final int? index;

  Recognition({
    this.label,
    this.confidence,
    this.index,
  });

  /// Create Recognition from JSON
  factory Recognition.fromJson(Map<String, dynamic> json) {
    return Recognition(
      label: json['label'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      index: json['index'] as int?,
    );
  }

  /// Convert Recognition to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'index': index,
    };
  }

  @override
  String toString() {
    return 'Recognition(label: $label, confidence: $confidence, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recognition &&
        other.label == label &&
        other.confidence == confidence &&
        other.index == index;
  }

  @override
  int get hashCode {
    return label.hashCode ^ confidence.hashCode ^ index.hashCode;
  }
}