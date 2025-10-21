/// Enum for different types of TensorFlow Lite models
enum ModelType {
  /// Image classification model
  imageClassification('image_classification'),
  
  /// Object detection model
  objectDetection('object_detection'),
  
  /// Pose estimation model (PoseNet)
  poseEstimation('pose_estimation'),
  
  /// Semantic segmentation model
  imageSegmentation('image_segmentation'),
  
  /// Style transfer model
  styleTransfer('style_transfer'),
  
  /// Super resolution model
  superResolution('super_resolution'),
  
  /// Text classification model
  textClassification('text_classification'),
  
  /// Question answering model (BERT)
  questionAnswering('question_answering'),
  
  /// Audio classification model
  audioClassification('audio_classification'),
  
  /// Speech recognition model
  speechRecognition('speech_recognition'),
  
  /// Gesture classification model
  gestureClassification('gesture_classification'),
  
  /// Digit classification model
  digitClassification('digit_classification'),
  
  /// Reinforcement learning model
  reinforcementLearning('reinforcement_learning'),
  
  /// Custom model type
  custom('custom');

  const ModelType(this.value);
  
  /// String value of the model type
  final String value;

  /// Create ModelType from string value
  static ModelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image_classification':
      case 'classification':
        return ModelType.imageClassification;
      case 'object_detection':
        return ModelType.objectDetection;
      case 'pose_estimation':
        return ModelType.poseEstimation;
      case 'image_segmentation':
      case 'segmentation':
        return ModelType.imageSegmentation;
      case 'style_transfer':
        return ModelType.styleTransfer;
      case 'super_resolution':
        return ModelType.superResolution;
      case 'text_classification':
        return ModelType.textClassification;
      case 'question_answering':
        return ModelType.questionAnswering;
      case 'audio_classification':
        return ModelType.audioClassification;
      case 'speech_recognition':
        return ModelType.speechRecognition;
      case 'gesture_classification':
        return ModelType.gestureClassification;
      case 'digit_classification':
        return ModelType.digitClassification;
      case 'reinforcement_learning':
        return ModelType.reinforcementLearning;
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