/// Enum for different types of TensorFlow Lite models
enum ModelType {
  /// Image classification model
  classification('classification'),
  
  /// Object detection model
  objectDetection('object_detection'),
  
  /// Pose estimation model (PoseNet)
  poseEstimation('pose_estimation'),
  
  /// Semantic segmentation model
  segmentation('segmentation'),
  
  /// Custom model type
  custom('custom');

  const ModelType(this.value);
  
  /// String value of the model type
  final String value;

  /// Create ModelType from string value
  static ModelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'classification':
        return ModelType.classification;
      case 'object_detection':
        return ModelType.objectDetection;
      case 'pose_estimation':
        return ModelType.poseEstimation;
      case 'segmentation':
        return ModelType.segmentation;
      case 'custom':
      default:
        return ModelType.custom;
    }
  }

  @override
  String toString() => value;
}

/// Enum for different delegate types
enum DelegateType {
  /// CPU delegate (default)
  cpu('cpu'),
  
  /// GPU delegate for acceleration
  gpu('gpu'),
  
  /// NNAPI delegate for Android
  nnapi('nnapi'),
  
  /// Metal delegate for iOS
  metal('metal'),
  
  /// CoreML delegate for iOS
  coreml('coreml');

  const DelegateType(this.value);
  
  /// String value of the delegate type
  final String value;

  /// Create DelegateType from string value
  static DelegateType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cpu':
        return DelegateType.cpu;
      case 'gpu':
        return DelegateType.gpu;
      case 'nnapi':
        return DelegateType.nnapi;
      case 'metal':
        return DelegateType.metal;
      case 'coreml':
        return DelegateType.coreml;
      default:
        return DelegateType.cpu;
    }
  }

  @override
  String toString() => value;
}