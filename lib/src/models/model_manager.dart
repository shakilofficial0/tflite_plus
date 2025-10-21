import '../../tflite_plus_platform_interface.dart';
import '../enums/model_type.dart';
import '../models/model_config.dart';

/// Manager class for handling multiple TensorFlow Lite models
class TfLiteModelManager {
  static final Map<String, LoadedModel> _loadedModels = {};
  static String? _currentModelId;

  /// Load a model with configuration
  static Future<LoadedModel> loadModel(TfLiteModelConfig config) async {
    // Close current model if loading a new one
    if (_currentModelId != null && _currentModelId != config.id) {
      await closeModel(_currentModelId!);
    }

    final result = await TflitePlusPlatform.instance.loadModel(
      model: config.modelPath,
      labels: config.labelsPath,
      numThreads: config.numThreads,
      isAsset: config.isAsset,
      useGpuDelegate: config.useGpuDelegate,
      useNnApiDelegate: config.useNnApiDelegate,
    );

    if (result == null) {
      throw Exception('Failed to load model: ${config.id}');
    }

    // Get model shapes
    final inputShape = await TflitePlusPlatform.instance.getModelInputShape();
    final outputShape = await TflitePlusPlatform.instance.getModelOutputShape();

    // Load labels if specified
    List<String>? labels;
    if (config.labelsPath != null) {
      // Labels are loaded by the platform implementation
      labels = null; // Platform handles label loading
    }

    final loadedModel = LoadedModel(
      config: config,
      isLoaded: true,
      loadedAt: DateTime.now(),
      labels: labels,
      actualInputShape: inputShape,
      actualOutputShape: outputShape,
    );

    _loadedModels[config.id] = loadedModel;
    _currentModelId = config.id;

    return loadedModel;
  }

  /// Switch to a different loaded model
  static Future<LoadedModel?> switchToModel(String modelId) async {
    if (!_loadedModels.containsKey(modelId)) {
      return null;
    }

    final model = _loadedModels[modelId]!;

    // Reload the model if it's not the current one
    if (_currentModelId != modelId) {
      await loadModel(model.config);
    }

    return model;
  }

  /// Get currently active model
  static LoadedModel? getCurrentModel() {
    if (_currentModelId == null) return null;
    return _loadedModels[_currentModelId];
  }

  /// Get a specific loaded model by ID
  static LoadedModel? getModel(String modelId) {
    return _loadedModels[modelId];
  }

  /// Get all loaded models
  static Map<String, LoadedModel> getAllModels() {
    return Map.unmodifiable(_loadedModels);
  }

  /// Check if a model is loaded
  static bool isModelLoaded(String modelId) {
    return _loadedModels.containsKey(modelId) &&
        _loadedModels[modelId]!.isLoaded;
  }

  /// Close a specific model
  static Future<void> closeModel(String modelId) async {
    if (_loadedModels.containsKey(modelId)) {
      if (_currentModelId == modelId) {
        await TflitePlusPlatform.instance.close();
        _currentModelId = null;
      }
      _loadedModels.remove(modelId);
    }
  }

  /// Close all models
  static Future<void> closeAllModels() async {
    await TflitePlusPlatform.instance.close();
    _loadedModels.clear();
    _currentModelId = null;
  }

  /// Get available delegates
  static Future<List<String>?> getAvailableDelegates() {
    return TflitePlusPlatform.instance.getAvailableDelegates();
  }
}

/// Predefined model configurations for common models
class PredefinedModels {
  /// MobileNet V1 for image classification
  static const mobilenetV1 = TfLiteModelConfig(
    id: 'mobilenet_v1',
    modelPath: 'assets/models/mobilenet_v1_1.0_224.tflite',
    labelsPath: 'assets/models/mobilenet_v1_1.0_224_labels.txt',
    modelType: ModelType.imageClassification,
    inputConfig: ModelInputConfig(width: 224, height: 224, channels: 3),
    outputConfig: ModelOutputConfig(numClasses: 1000),
    preprocessingConfig: PreprocessingConfig(imageMean: 117.0, imageStd: 1.0),
  );

  /// MobileNet SSD for object detection
  static const mobilenetSSD = TfLiteModelConfig(
    id: 'mobilenet_ssd',
    modelPath: 'assets/models/ssd_mobilenet_v1_1_metadata_1.tflite',
    labelsPath: 'assets/models/ssd_mobilenet_v1_1_labels.txt',
    modelType: ModelType.objectDetection,
    inputConfig: ModelInputConfig(width: 300, height: 300, channels: 3),
    outputConfig: ModelOutputConfig(numClasses: 91, hasBoundingBoxes: true),
    preprocessingConfig: PreprocessingConfig(imageMean: 127.5, imageStd: 127.5),
  );

  /// PoseNet for pose estimation
  static const poseNet = TfLiteModelConfig(
    id: 'posenet',
    modelPath: 'assets/models/posenet_model.tflite',
    modelType: ModelType.poseEstimation,
    inputConfig: ModelInputConfig(width: 257, height: 257, channels: 3),
    outputConfig: ModelOutputConfig(hasKeypoints: true),
    preprocessingConfig: PreprocessingConfig(imageMean: 127.5, imageStd: 127.5),
  );

  /// DeepLab for image segmentation
  static const deepLabV3 = TfLiteModelConfig(
    id: 'deeplabv3',
    modelPath: 'assets/models/deeplabv3_257_mv_gpu.tflite',
    modelType: ModelType.imageSegmentation,
    inputConfig: ModelInputConfig(width: 257, height: 257, channels: 3),
    outputConfig: ModelOutputConfig(numClasses: 21, isSegmentation: true),
    preprocessingConfig: PreprocessingConfig(imageMean: 127.5, imageStd: 127.5),
  );

  /// BERT for question answering
  static const bertQA = TfLiteModelConfig(
    id: 'bert_qa',
    modelPath: 'assets/models/mobilebert_1_default_1.tflite',
    modelType: ModelType.questionAnswering,
    inputConfig: ModelInputConfig(
      width: 384, // sequence length
      height: 1,
      channels: 1,
    ),
    outputConfig: ModelOutputConfig(
      numClasses: 2, // start and end positions
    ),
  );

  /// Text classification model
  static const textClassifier = TfLiteModelConfig(
    id: 'text_classification',
    modelPath: 'assets/models/text_classification_model.tflite',
    modelType: ModelType.textClassification,
    inputConfig: ModelInputConfig(
      width: 256, // sequence length
      height: 1,
      channels: 1,
    ),
    outputConfig: ModelOutputConfig(
      numClasses: 2, // positive/negative
    ),
  );

  /// Audio classification model
  static const audioClassifier = TfLiteModelConfig(
    id: 'audio_classification',
    modelPath: 'assets/models/yamnet.tflite',
    labelsPath: 'assets/models/yamnet_labels.txt',
    modelType: ModelType.audioClassification,
    inputConfig: ModelInputConfig(
      width: 15600, // audio samples
      height: 1,
      channels: 1,
    ),
    outputConfig: ModelOutputConfig(numClasses: 521),
  );

  /// Gesture classification model
  static const gestureClassifier = TfLiteModelConfig(
    id: 'gesture_classification',
    modelPath: 'assets/models/gesture_classifier.tflite',
    labelsPath: 'assets/models/gesture_labels.txt',
    modelType: ModelType.gestureClassification,
    inputConfig: ModelInputConfig(width: 224, height: 224, channels: 3),
    outputConfig: ModelOutputConfig(numClasses: 4),
  );

  /// Digit classification model (MNIST)
  static const digitClassifier = TfLiteModelConfig(
    id: 'digit_classification',
    modelPath: 'assets/models/mnist_model.tflite',
    modelType: ModelType.digitClassification,
    inputConfig: ModelInputConfig(width: 28, height: 28, channels: 1),
    outputConfig: ModelOutputConfig(numClasses: 10),
    preprocessingConfig: PreprocessingConfig(imageMean: 0.0, imageStd: 255.0),
  );

  /// Style transfer model
  static const styleTransfer = TfLiteModelConfig(
    id: 'style_transfer',
    modelPath:
        'assets/models/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite',
    modelType: ModelType.styleTransfer,
    inputConfig: ModelInputConfig(width: 256, height: 256, channels: 3),
    outputConfig: ModelOutputConfig(),
  );

  /// Super resolution model
  static const superResolution = TfLiteModelConfig(
    id: 'super_resolution',
    modelPath: 'assets/models/esrgan-tf2_1.tflite',
    modelType: ModelType.superResolution,
    inputConfig: ModelInputConfig(width: 50, height: 50, channels: 3),
    outputConfig: ModelOutputConfig(),
  );

  /// Get all predefined models
  static List<TfLiteModelConfig> getAllPredefined() {
    return [
      mobilenetV1,
      mobilenetSSD,
      poseNet,
      deepLabV3,
      bertQA,
      textClassifier,
      audioClassifier,
      gestureClassifier,
      digitClassifier,
      styleTransfer,
      superResolution,
    ];
  }
}
