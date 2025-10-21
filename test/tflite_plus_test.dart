import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_plus/tflite_plus.dart';
import 'package:tflite_plus/tflite_plus_platform_interface.dart';
import 'package:tflite_plus/tflite_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTflitePlusPlatform
    with MockPlatformInterfaceMixin
    implements TflitePlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TflitePlusPlatform initialPlatform = TflitePlusPlatform.instance;

  test('$MethodChannelTflitePlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTflitePlus>());
  });

  test('getPlatformVersion', () async {
    TflitePlus tflitePlusPlugin = TflitePlus();
    MockTflitePlusPlatform fakePlatform = MockTflitePlusPlatform();
    TflitePlusPlatform.instance = fakePlatform;

    expect(await tflitePlusPlugin.getPlatformVersion(), '42');
  });
}
