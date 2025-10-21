import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tflite_plus_method_channel.dart';

abstract class TflitePlusPlatform extends PlatformInterface {
  /// Constructs a TflitePlusPlatform.
  TflitePlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static TflitePlusPlatform _instance = MethodChannelTflitePlus();

  /// The default instance of [TflitePlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelTflitePlus].
  static TflitePlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TflitePlusPlatform] when
  /// they register themselves.
  static set instance(TflitePlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApiDelegate = false,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  Future<List<dynamic>?> detectObjectOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    int numResultsPerClass = 5,
    double threshold = 0.1,
    bool asynch = true,
  }) {
    throw UnimplementedError('detectObjectOnImage() has not been implemented.');
  }

  Future<List<dynamic>?> detectObjectOnBinary({
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
    throw UnimplementedError('detectObjectOnBinary() has not been implemented.');
  }

  Future<List<dynamic>?> runModelOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) {
    throw UnimplementedError('runModelOnImage() has not been implemented.');
  }

  Future<List<dynamic>?> runModelOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) {
    throw UnimplementedError('runModelOnBinary() has not been implemented.');
  }

  Future<List<dynamic>?> runPoseNetOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) {
    throw UnimplementedError('runPoseNetOnImage() has not been implemented.');
  }

  Future<List<dynamic>?> runPoseNetOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) {
    throw UnimplementedError('runPoseNetOnBinary() has not been implemented.');
  }

  Future<dynamic> runSegmentationOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) {
    throw UnimplementedError('runSegmentationOnImage() has not been implemented.');
  }

  Future<dynamic> runSegmentationOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) {
    throw UnimplementedError('runSegmentationOnBinary() has not been implemented.');
  }

  Future<void> close() {
    throw UnimplementedError('close() has not been implemented.');
  }

  Future<List<int>?> getModelInputShape() {
    throw UnimplementedError('getModelInputShape() has not been implemented.');
  }

  Future<List<int>?> getModelOutputShape() {
    throw UnimplementedError('getModelOutputShape() has not been implemented.');
  }

  Future<bool> isModelLoaded() {
    throw UnimplementedError('isModelLoaded() has not been implemented.');
  }

  Future<List<String>?> getAvailableDelegates() {
    throw UnimplementedError('getAvailableDelegates() has not been implemented.');
  }
}
