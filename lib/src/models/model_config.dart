import '../enums/model_type.dart';

/// Configuration for TensorFlow Lite model loading and inference
class TfLiteModelConfig {
  /// Unique identifier for the model
  final String id;
  
  /// Path to the .tflite model file
  final String modelPath;
  
  /// Optional path to labels file
  final String? labelsPath;
  
  /// Number of threads to use for inference
  final int numThreads;
  
  /// Whether the model files are in assets
  final bool isAsset;
  
  /// Use GPU acceleration if available
  final bool useGpuDelegate;
  
  /// Use NNAPI on Android or CoreML on iOS
  final bool useNnApiDelegate;
  
  /// Model type for optimization and validation
  final ModelType modelType;
  
  /// Input image dimensions
  final ModelInputConfig inputConfig;
  
  /// Output configuration
  final ModelOutputConfig outputConfig;
  
  /// Optional preprocessing configuration
  final PreprocessingConfig? preprocessingConfig;

  const TfLiteModelConfig({
    required this.id,
    required this.modelPath,
    this.labelsPath,
    this.numThreads = 1,
    this.isAsset = true,
    this.useGpuDelegate = false,
    this.useNnApiDelegate = false,
    required this.modelType,
    required this.inputConfig,
    required this.outputConfig,
    this.preprocessingConfig,
  });

  /// Create a copy with updated values
  TfLiteModelConfig copyWith({
    String? id,
    String? modelPath,
    String? labelsPath,
    int? numThreads,
    bool? isAsset,
    bool? useGpuDelegate,
    bool? useNnApiDelegate,
    ModelType? modelType,
    ModelInputConfig? inputConfig,
    ModelOutputConfig? outputConfig,
    PreprocessingConfig? preprocessingConfig,
  }) {
    return TfLiteModelConfig(
      id: id ?? this.id,
      modelPath: modelPath ?? this.modelPath,
      labelsPath: labelsPath ?? this.labelsPath,
      numThreads: numThreads ?? this.numThreads,
      isAsset: isAsset ?? this.isAsset,
      useGpuDelegate: useGpuDelegate ?? this.useGpuDelegate,
      useNnApiDelegate: useNnApiDelegate ?? this.useNnApiDelegate,
      modelType: modelType ?? this.modelType,
      inputConfig: inputConfig ?? this.inputConfig,
      outputConfig: outputConfig ?? this.outputConfig,
      preprocessingConfig: preprocessingConfig ?? this.preprocessingConfig,
    );
  }

  @override
  String toString() {
    return 'TfLiteModelConfig(id: $id, modelPath: $modelPath, modelType: $modelType)';
  }
}

/// Model input configuration
class ModelInputConfig {
  /// Input image width
  final int width;
  
  /// Input image height
  final int height;
  
  /// Number of channels (1 for grayscale, 3 for RGB)
  final int channels;
  
  /// Batch size (usually 1 for mobile inference)
  final int batchSize;
  
  /// Input data type
  final ModelDataType dataType;

  const ModelInputConfig({
    required this.width,
    required this.height,
    this.channels = 3,
    this.batchSize = 1,
    this.dataType = ModelDataType.float32,
  });

  /// Get input shape as list
  List<int> get shape => [batchSize, height, width, channels];

  @override
  String toString() {
    return 'ModelInputConfig(${width}x${height}x$channels, batch: $batchSize, type: $dataType)';
  }
}

/// Model output configuration
class ModelOutputConfig {
  /// Number of output classes (for classification)
  final int? numClasses;
  
  /// Output data type
  final ModelDataType dataType;
  
  /// Whether output includes bounding boxes (for detection)
  final bool hasBoundingBoxes;
  
  /// Whether output includes keypoints (for pose estimation)
  final bool hasKeypoints;
  
  /// Whether output is segmentation mask
  final bool isSegmentation;

  const ModelOutputConfig({
    this.numClasses,
    this.dataType = ModelDataType.float32,
    this.hasBoundingBoxes = false,
    this.hasKeypoints = false,
    this.isSegmentation = false,
  });

  @override
  String toString() {
    return 'ModelOutputConfig(classes: $numClasses, type: $dataType, bbox: $hasBoundingBoxes, keypoints: $hasKeypoints, segmentation: $isSegmentation)';
  }
}

/// Preprocessing configuration
class PreprocessingConfig {
  /// Image mean for normalization
  final double imageMean;
  
  /// Image standard deviation for normalization
  final double imageStd;
  
  /// Whether to resize image to model input size
  final bool autoResize;
  
  /// Whether to normalize pixel values
  final bool normalize;

  const PreprocessingConfig({
    this.imageMean = 127.5,
    this.imageStd = 127.5,
    this.autoResize = true,
    this.normalize = true,
  });

  @override
  String toString() {
    return 'PreprocessingConfig(mean: $imageMean, std: $imageStd, resize: $autoResize, normalize: $normalize)';
  }
}

/// Data types supported by TensorFlow Lite
enum ModelDataType {
  float32,
  int8,
  uint8,
  int16,
  int32,
  int64,
}



/// Loaded model instance with metadata and state
class LoadedModel {
  /// Model configuration
  final TfLiteModelConfig config;
  
  /// Whether the model is currently loaded
  final bool isLoaded;
  
  /// Load timestamp
  final DateTime loadedAt;
  
  /// Labels if available
  final List<String>? labels;
  
  /// Actual input shape from the loaded model
  final List<int>? actualInputShape;
  
  /// Actual output shape from the loaded model
  final List<int>? actualOutputShape;

  const LoadedModel({
    required this.config,
    required this.isLoaded,
    required this.loadedAt,
    this.labels,
    this.actualInputShape,
    this.actualOutputShape,
  });

  @override
  String toString() {
    return 'LoadedModel(id: ${config.id}, loaded: $isLoaded, type: ${config.modelType})';
  }
}