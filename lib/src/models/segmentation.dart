import 'dart:typed_data';

/// Represents segmentation mask data
class SegmentationMask {
  /// Width of the segmentation mask
  final int width;
  
  /// Height of the segmentation mask
  final int height;
  
  /// Raw mask data as bytes
  final Uint8List mask;
  
  /// Number of classes in the segmentation
  final int? numClasses;

  SegmentationMask({
    required this.width,
    required this.height,
    required this.mask,
    this.numClasses,
  });

  /// Create SegmentationMask from JSON
  factory SegmentationMask.fromJson(Map<String, dynamic> json) {
    final maskData = json['mask'];
    Uint8List mask;
    
    if (maskData is List<int>) {
      mask = Uint8List.fromList(maskData);
    } else if (maskData is String) {
      // Assume base64 encoded
      mask = Uint8List.fromList(maskData.codeUnits);
    } else {
      throw ArgumentError('Invalid mask data format');
    }
    
    return SegmentationMask(
      width: json['width'] as int,
      height: json['height'] as int,
      mask: mask,
      numClasses: json['numClasses'] as int?,
    );
  }

  /// Convert SegmentationMask to JSON
  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'mask': mask.toList(),
      'numClasses': numClasses,
    };
  }

  /// Get pixel class at specific coordinates
  int getPixelClass(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw ArgumentError('Coordinates out of bounds');
    }
    final index = y * width + x;
    return mask[index];
  }

  @override
  String toString() {
    return 'SegmentationMask(width: $width, height: $height, classes: $numClasses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SegmentationMask &&
        other.width == width &&
        other.height == height &&
        other.numClasses == numClasses;
  }

  @override
  int get hashCode {
    return width.hashCode ^ height.hashCode ^ numClasses.hashCode;
  }
}

/// Represents the result of semantic segmentation
class Segmentation {
  /// The segmentation mask
  final SegmentationMask mask;
  
  /// Optional image path if segmentation was saved as image
  final String? imagePath;
  
  /// Label colors mapping
  final Map<int, Map<String, int>>? labelColors;

  Segmentation({
    required this.mask,
    this.imagePath,
    this.labelColors,
  });

  /// Create Segmentation from JSON
  factory Segmentation.fromJson(Map<String, dynamic> json) {
    Map<int, Map<String, int>>? labelColors;
    
    if (json['labelColors'] != null) {
      final colorsMap = json['labelColors'] as Map<String, dynamic>;
      labelColors = {};
      colorsMap.forEach((key, value) {
        labelColors![int.parse(key)] = Map<String, int>.from(value);
      });
    }
    
    return Segmentation(
      mask: SegmentationMask.fromJson(json['mask']),
      imagePath: json['imagePath'] as String?,
      labelColors: labelColors,
    );
  }

  /// Convert Segmentation to JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic>? colorsMap;
    
    if (labelColors != null) {
      colorsMap = {};
      labelColors!.forEach((key, value) {
        colorsMap![key.toString()] = value;
      });
    }
    
    return {
      'mask': mask.toJson(),
      'imagePath': imagePath,
      'labelColors': colorsMap,
    };
  }

  @override
  String toString() {
    return 'Segmentation(mask: $mask, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Segmentation &&
        other.mask == mask &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    return mask.hashCode ^ imagePath.hashCode;
  }
}