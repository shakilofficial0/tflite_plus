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
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
