import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_plus/tflite_plus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTflitePlus platform = MethodChannelTflitePlus();
  const MethodChannel channel = MethodChannel('tflite_plus');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return '42';
            case 'loadModel':
              return 'Model loaded successfully';
            case 'detectObjectOnImage':
              return [
                {
                  'label': 'test_object',
                  'confidence': 0.85,
                  'rect': {'x': 0.1, 'y': 0.2, 'w': 0.3, 'h': 0.4},
                },
              ];
            case 'runModelOnImage':
              return [
                {'label': 'test_class', 'confidence': 0.92, 'index': 0},
              ];
            case 'getModelInputShape':
              return [1, 224, 224, 3];
            case 'getModelOutputShape':
              return [1, 1000];
            case 'isModelLoaded':
              return true;
            case 'getAvailableDelegates':
              return ['CPU', 'GPU'];
            case 'close':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('loadModel', () async {
    final result = await platform.loadModel(
      model: 'test_model.tflite',
      labels: 'test_labels.txt',
    );
    expect(result, 'Model loaded successfully');
  });

  test('detectObjectOnImage', () async {
    final results = await platform.detectObjectOnImage(path: 'test_image.jpg');
    expect(results, isNotEmpty);
    expect(results!.first['label'], 'test_object');
  });

  test('runModelOnImage', () async {
    final results = await platform.runModelOnImage(path: 'test_image.jpg');
    expect(results, isNotEmpty);
    expect(results!.first['label'], 'test_class');
  });

  test('getModelInputShape', () async {
    final shape = await platform.getModelInputShape();
    expect(shape, [1, 224, 224, 3]);
  });

  test('getModelOutputShape', () async {
    final shape = await platform.getModelOutputShape();
    expect(shape, [1, 1000]);
  });

  test('isModelLoaded', () async {
    final isLoaded = await platform.isModelLoaded();
    expect(isLoaded, true);
  });

  test('getAvailableDelegates', () async {
    final delegates = await platform.getAvailableDelegates();
    expect(delegates, contains('CPU'));
    expect(delegates, contains('GPU'));
  });

  test('close', () async {
    await platform.close();
    // Should complete without throwing
  });
}
