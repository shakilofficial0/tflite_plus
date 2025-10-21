/// Represents a bounding box for detected objects
class BoundingBox {
  /// X coordinate of the top-left corner
  final double x;
  
  /// Y coordinate of the top-left corner
  final double y;
  
  /// Width of the bounding box
  final double width;
  
  /// Height of the bounding box
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Create BoundingBox from JSON
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['w'] as num).toDouble(),
      height: (json['h'] as num).toDouble(),
    );
  }

  /// Convert BoundingBox to JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'w': width,
      'h': height,
    };
  }

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }
}

/// Represents a detected object with bounding box and classification
class Detection {
  /// The bounding box of the detected object
  final BoundingBox boundingBox;
  
  /// The classification label
  final String? label;
  
  /// The confidence score (0.0 to 1.0)
  final double? confidence;
  
  /// The index of the detected class
  final int? detectedClass;

  Detection({
    required this.boundingBox,
    this.label,
    this.confidence,
    this.detectedClass,
  });

  /// Create Detection from JSON
  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      boundingBox: BoundingBox.fromJson(json['rect'] ?? json['boundingBox']),
      label: json['label'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      detectedClass: json['detectedClass'] as int?,
    );
  }

  /// Convert Detection to JSON
  Map<String, dynamic> toJson() {
    return {
      'rect': boundingBox.toJson(),
      'label': label,
      'confidence': confidence,
      'detectedClass': detectedClass,
    };
  }

  @override
  String toString() {
    return 'Detection(boundingBox: $boundingBox, label: $label, confidence: $confidence, detectedClass: $detectedClass)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Detection &&
        other.boundingBox == boundingBox &&
        other.label == label &&
        other.confidence == confidence &&
        other.detectedClass == detectedClass;
  }

  @override
  int get hashCode {
    return boundingBox.hashCode ^
        label.hashCode ^
        confidence.hashCode ^
        detectedClass.hashCode;
  }
}