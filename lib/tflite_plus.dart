import 'dart:typed_data';

import 'tflite_plus_platform_interface.dart';

export 'src/enums/model_type.dart';
export 'src/models/detection.dart';
export 'src/models/pose.dart';
export 'src/models/recognition.dart';
export 'src/models/segmentation.dart';

/// The main class for TensorFlow Lite operations in Flutter
class TflitePlus {
  /// Load a TensorFlow Lite model from assets
  /// 
  /// [model] - Path to the .tflite model file in assets
  /// [labels] - Optional path to labels file
  /// [numThreads] - Number of threads to use (default: 1)
  /// [isAsset] - Whether the model is in assets (default: true)
  /// [useGpuDelegate] - Use GPU acceleration if available (default: false)
  /// [useNnApiDelegate] - Use NNAPI on Android (default: false)
  static Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApiDelegate = false,
  }) {
    return TflitePlusPlatform.instance.loadModel(
      model: model,
      labels: labels,
      numThreads: numThreads,
      isAsset: isAsset,
      useGpuDelegate: useGpuDelegate,
      useNnApiDelegate: useNnApiDelegate,
    );
  }

  /// Run object detection on an image
  /// 
  /// [path] - Path to the image file
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [numResultsPerClass] - Maximum results per class (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> detectObjectOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    int numResultsPerClass = 5,
    double threshold = 0.1,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.detectObjectOnImage(
      path: path,
      imageMean: imageMean,
      imageStd: imageStd,
      numResultsPerClass: numResultsPerClass,
      threshold: threshold,
      asynch: asynch,
    );
  }

  /// Run object detection on binary image data
  /// 
  /// [bytesList] - Image data as bytes
  /// [imageHeight] - Image height
  /// [imageWidth] - Image width
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [rotation] - Image rotation angle (default: 0)
  /// [numResultsPerClass] - Maximum results per class (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> detectObjectOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    double imageMean = 127.5,
    double imageStd = 127.5,
    int rotation = 0,
    int numResultsPerClass = 5,
    double threshold = 0.1,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.detectObjectOnBinary(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      imageMean: imageMean,
      imageStd: imageStd,
      rotation: rotation,
      numResultsPerClass: numResultsPerClass,
      threshold: threshold,
      asynch: asynch,
    );
  }

  /// Run image classification on an image
  /// 
  /// [path] - Path to the image file
  /// [numResults] - Maximum number of results (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [imageMean] - Image mean for normalization (default: 117.0)
  /// [imageStd] - Image standard deviation for normalization (default: 1.0)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> runModelOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runModelOnImage(
      path: path,
      numResults: numResults,
      threshold: threshold,
      imageMean: imageMean,
      imageStd: imageStd,
      asynch: asynch,
    );
  }

  /// Run image classification on binary image data
  /// 
  /// [bytesList] - Image data as bytes
  /// [imageHeight] - Image height
  /// [imageWidth] - Image width
  /// [numResults] - Maximum number of results (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [imageMean] - Image mean for normalization (default: 117.0)
  /// [imageStd] - Image standard deviation for normalization (default: 1.0)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> runModelOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runModelOnBinary(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      numResults: numResults,
      threshold: threshold,
      imageMean: imageMean,
      imageStd: imageStd,
      asynch: asynch,
    );
  }

  /// Run pose estimation on an image
  /// 
  /// [path] - Path to the image file
  /// [numResults] - Maximum number of poses (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> runPoseNetOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runPoseNetOnImage(
      path: path,
      numResults: numResults,
      threshold: threshold,
      imageMean: imageMean,
      imageStd: imageStd,
      asynch: asynch,
    );
  }

  /// Run pose estimation on binary image data
  /// 
  /// [bytesList] - Image data as bytes
  /// [imageHeight] - Image height
  /// [imageWidth] - Image width
  /// [numResults] - Maximum number of poses (default: 5)
  /// [threshold] - Confidence threshold (default: 0.1)
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [asynch] - Run asynchronously (default: true)
  static Future<List<dynamic>?> runPoseNetOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runPoseNetOnBinary(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      numResults: numResults,
      threshold: threshold,
      imageMean: imageMean,
      imageStd: imageStd,
      asynch: asynch,
    );
  }

  /// Run semantic segmentation on an image
  /// 
  /// [path] - Path to the image file
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [labelColors] - Colors for different labels
  /// [outputType] - Output format (default: "png")
  /// [asynch] - Run asynchronously (default: true)
  static Future<dynamic> runSegmentationOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runSegmentationOnImage(
      path: path,
      imageMean: imageMean,
      imageStd: imageStd,
      labelColors: labelColors,
      outputType: outputType,
      asynch: asynch,
    );
  }

  /// Run semantic segmentation on binary image data
  /// 
  /// [bytesList] - Image data as bytes
  /// [imageHeight] - Image height
  /// [imageWidth] - Image width
  /// [imageMean] - Image mean for normalization (default: 127.5)
  /// [imageStd] - Image standard deviation for normalization (default: 127.5)
  /// [labelColors] - Colors for different labels
  /// [outputType] - Output format (default: "png")
  /// [asynch] - Run asynchronously (default: true)
  static Future<dynamic> runSegmentationOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) {
    return TflitePlusPlatform.instance.runSegmentationOnBinary(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      imageMean: imageMean,
      imageStd: imageStd,
      labelColors: labelColors,
      outputType: outputType,
      asynch: asynch,
    );
  }

  /// Close the loaded model and free resources
  static Future<void> close() {
    return TflitePlusPlatform.instance.close();
  }

  /// Get model input shape
  static Future<List<int>?> getModelInputShape() {
    return TflitePlusPlatform.instance.getModelInputShape();
  }

  /// Get model output shape
  static Future<List<int>?> getModelOutputShape() {
    return TflitePlusPlatform.instance.getModelOutputShape();
  }

  /// Check if model is loaded
  static Future<bool> isModelLoaded() {
    return TflitePlusPlatform.instance.isModelLoaded();
  }

  /// Get platform version
  static Future<String?> getPlatformVersion() {
    return TflitePlusPlatform.instance.getPlatformVersion();
  }

  /// Get available delegates
  static Future<List<String>?> getAvailableDelegates() {
    return TflitePlusPlatform.instance.getAvailableDelegates();
  }
}
