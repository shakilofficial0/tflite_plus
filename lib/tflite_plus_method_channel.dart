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
}
