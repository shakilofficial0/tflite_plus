/// Represents a keypoint in pose estimation
class Keypoint {
  /// X coordinate of the keypoint
  final double x;

  /// Y coordinate of the keypoint
  final double y;

  /// Confidence score of the keypoint (0.0 to 1.0)
  final double confidence;

  /// Name of the body part
  final String? part;

  Keypoint({
    required this.x,
    required this.y,
    required this.confidence,
    this.part,
  });

  /// Create Keypoint from JSON
  factory Keypoint.fromJson(Map<String, dynamic> json) {
    return Keypoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      part: json['part'] as String?,
    );
  }

  /// Convert Keypoint to JSON
  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'confidence': confidence, 'part': part};
  }

  @override
  String toString() {
    return 'Keypoint(x: $x, y: $y, confidence: $confidence, part: $part)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Keypoint &&
        other.x == x &&
        other.y == y &&
        other.confidence == confidence &&
        other.part == part;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode ^ confidence.hashCode ^ part.hashCode;
  }
}

/// Represents a detected pose with keypoints
class Pose {
  /// List of keypoints that make up the pose
  final List<Keypoint> keypoints;

  /// Overall confidence score of the pose (0.0 to 1.0)
  final double? confidence;

  Pose({required this.keypoints, this.confidence});

  /// Create Pose from JSON
  factory Pose.fromJson(Map<String, dynamic> json) {
    final keypointsJson = json['keypoints'] as List<dynamic>? ?? [];
    final keypoints = keypointsJson
        .map((e) => Keypoint.fromJson(e as Map<String, dynamic>))
        .toList();

    return Pose(
      keypoints: keypoints,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  /// Convert Pose to JSON
  Map<String, dynamic> toJson() {
    return {
      'keypoints': keypoints.map((e) => e.toJson()).toList(),
      'confidence': confidence,
    };
  }

  /// Get keypoint by body part name
  Keypoint? getKeypoint(String part) {
    try {
      return keypoints.firstWhere((kp) => kp.part == part);
    } catch (e) {
      return null;
    }
  }

  /// Get all keypoints above confidence threshold
  List<Keypoint> getValidKeypoints(double threshold) {
    return keypoints.where((kp) => kp.confidence >= threshold).toList();
  }

  @override
  String toString() {
    return 'Pose(keypoints: ${keypoints.length}, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pose &&
        other.keypoints.length == keypoints.length &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return keypoints.hashCode ^ confidence.hashCode;
  }
}
