import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tflite_plus_platform_interface.dart';

/// An implementation of [TflitePlusPlatform] that uses method channels.
class MethodChannelTflitePlus extends TflitePlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tflite_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApiDelegate = false,
  }) async {
    final result = await methodChannel.invokeMethod<String>('loadModel', {
      'model': model,
      'labels': labels,
      'numThreads': numThreads,
      'isAsset': isAsset,
      'useGpuDelegate': useGpuDelegate,
      'useNnApiDelegate': useNnApiDelegate,
    });
    return result;
  }

  @override
  Future<List<dynamic>?> detectObjectOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    int numResultsPerClass = 5,
    double threshold = 0.1,
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('detectObjectOnImage', {
      'path': path,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'numResultsPerClass': numResultsPerClass,
      'threshold': threshold,
      'asynch': asynch,
    });
    return result;
  }

  @override
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
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('detectObjectOnBinary', {
      'bytesList': bytesList,
      'imageHeight': imageHeight,
      'imageWidth': imageWidth,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'rotation': rotation,
      'numResultsPerClass': numResultsPerClass,
      'threshold': threshold,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<List<dynamic>?> runModelOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('runModelOnImage', {
      'path': path,
      'numResults': numResults,
      'threshold': threshold,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<List<dynamic>?> runModelOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('runModelOnBinary', {
      'bytesList': bytesList,
      'imageHeight': imageHeight,
      'imageWidth': imageWidth,
      'numResults': numResults,
      'threshold': threshold,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<List<dynamic>?> runPoseNetOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('runPoseNetOnImage', {
      'path': path,
      'numResults': numResults,
      'threshold': threshold,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<List<dynamic>?> runPoseNetOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('runPoseNetOnBinary', {
      'bytesList': bytesList,
      'imageHeight': imageHeight,
      'imageWidth': imageWidth,
      'numResults': numResults,
      'threshold': threshold,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<dynamic> runSegmentationOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod('runSegmentationOnImage', {
      'path': path,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'labelColors': labelColors,
      'outputType': outputType,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<dynamic> runSegmentationOnBinary({
    required Uint8List bytesList,
    required int imageHeight,
    required int imageWidth,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) async {
    final result = await methodChannel.invokeMethod('runSegmentationOnBinary', {
      'bytesList': bytesList,
      'imageHeight': imageHeight,
      'imageWidth': imageWidth,
      'imageMean': imageMean,
      'imageStd': imageStd,
      'labelColors': labelColors,
      'outputType': outputType,
      'asynch': asynch,
    });
    return result;
  }

  @override
  Future<void> close() async {
    await methodChannel.invokeMethod<void>('close');
  }

  @override
  Future<List<int>?> getModelInputShape() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('getModelInputShape');
    return result?.cast<int>();
  }

  @override
  Future<List<int>?> getModelOutputShape() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('getModelOutputShape');
    return result?.cast<int>();
  }

  @override
  Future<bool> isModelLoaded() async {
    final result = await methodChannel.invokeMethod<bool>('isModelLoaded');
    return result ?? false;
  }

  @override
  Future<List<String>?> getAvailableDelegates() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('getAvailableDelegates');
    return result?.cast<String>();
  }
}
