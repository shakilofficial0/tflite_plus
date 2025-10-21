import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tflite_plus/tflite_plus.dart';
import 'package:tflite_plus/tflite_plus_method_channel.dart';
import 'package:tflite_plus/tflite_plus_platform_interface.dart';

class MockTflitePlusPlatform
    with MockPlatformInterfaceMixin
    implements TflitePlusPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> loadModel({
    required String model,
    String? labels,
    int numThreads = 1,
    bool isAsset = true,
    bool useGpuDelegate = false,
    bool useNnApiDelegate = false,
  }) => Future.value('Mock model loaded');

  @override
  Future<List<dynamic>?> detectObjectOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    int numResultsPerClass = 5,
    double threshold = 0.1,
    bool asynch = true,
  }) => Future.value([
    {
      'label': 'test_object',
      'confidence': 0.85,
      'rect': {'x': 0.1, 'y': 0.2, 'w': 0.3, 'h': 0.4},
    },
  ]);

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
  }) => Future.value([]);

  @override
  Future<List<dynamic>?> runModelOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 117.0,
    double imageStd = 1.0,
    bool asynch = true,
  }) => Future.value([
    {'label': 'test_class', 'confidence': 0.92, 'index': 0},
  ]);

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
  }) => Future.value([]);

  @override
  Future<List<dynamic>?> runPoseNetOnImage({
    required String path,
    int numResults = 5,
    double threshold = 0.1,
    double imageMean = 127.5,
    double imageStd = 127.5,
    bool asynch = true,
  }) => Future.value([
    {
      'keypoints': [
        {'x': 0.5, 'y': 0.3, 'part': 'nose', 'confidence': 0.9},
      ],
    },
  ]);

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
  }) => Future.value([]);

  @override
  Future<dynamic> runSegmentationOnImage({
    required String path,
    double imageMean = 127.5,
    double imageStd = 127.5,
    List<Map<String, int>>? labelColors,
    String outputType = "png",
    bool asynch = true,
  }) => Future.value({'path': '/mock/segmentation.png'});

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
  }) => Future.value({});

  @override
  Future<void> close() => Future.value();

  @override
  Future<List<int>?> getModelInputShape() => Future.value([1, 224, 224, 3]);

  @override
  Future<List<int>?> getModelOutputShape() => Future.value([1, 1000]);

  @override
  Future<bool> isModelLoaded() => Future.value(true);

  @override
  Future<List<String>?> getAvailableDelegates() => Future.value(['CPU', 'GPU']);
}

void main() {
  final TflitePlusPlatform initialPlatform = TflitePlusPlatform.instance;

  test('$MethodChannelTflitePlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTflitePlus>());
  });

  group('TflitePlus', () {
    late MockTflitePlusPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockTflitePlusPlatform();
      TflitePlusPlatform.instance = mockPlatform;
    });

    test('getPlatformVersion', () async {
      expect(await TflitePlus.getPlatformVersion(), '42');
    });

    test('loadModel', () async {
      final result = await TflitePlus.loadModel(
        model: 'test_model.tflite',
        labels: 'test_labels.txt',
      );
      expect(result, 'Mock model loaded');
    });

    test('detectObjectOnImage', () async {
      final results = await TflitePlus.detectObjectOnImage(
        path: 'test_image.jpg',
      );
      expect(results, isNotEmpty);
      expect(results!.first['label'], 'test_object');
      expect(results.first['confidence'], 0.85);
    });

    test('runModelOnImage', () async {
      final results = await TflitePlus.runModelOnImage(path: 'test_image.jpg');
      expect(results, isNotEmpty);
      expect(results!.first['label'], 'test_class');
      expect(results.first['confidence'], 0.92);
    });

    test('runPoseNetOnImage', () async {
      final results = await TflitePlus.runPoseNetOnImage(
        path: 'test_image.jpg',
      );
      expect(results, isNotEmpty);
      expect(results!.first['keypoints'], isNotEmpty);
    });

    test('runSegmentationOnImage', () async {
      final result = await TflitePlus.runSegmentationOnImage(
        path: 'test_image.jpg',
      );
      expect(result, isNotNull);
      expect(result['path'], '/mock/segmentation.png');
    });

    test('getModelInputShape', () async {
      final shape = await TflitePlus.getModelInputShape();
      expect(shape, [1, 224, 224, 3]);
    });

    test('getModelOutputShape', () async {
      final shape = await TflitePlus.getModelOutputShape();
      expect(shape, [1, 1000]);
    });

    test('isModelLoaded', () async {
      final isLoaded = await TflitePlus.isModelLoaded();
      expect(isLoaded, true);
    });

    test('getAvailableDelegates', () async {
      final delegates = await TflitePlus.getAvailableDelegates();
      expect(delegates, contains('CPU'));
      expect(delegates, contains('GPU'));
    });

    test('close', () async {
      // Should complete without throwing
      await TflitePlus.close();
    });
  });
}
