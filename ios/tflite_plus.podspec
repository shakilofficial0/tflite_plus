Pod::Spec.new do |s|
  s.name             = 'tflite_plus'
  s.version          = '1.0.0'
  s.summary          = 'A comprehensive Flutter plugin for Google AI LiteRT (TensorFlow Lite).'
  s.description      = <<-DESC
A comprehensive Flutter plugin for Google AI's LiteRT (TensorFlow Lite) with advanced machine learning capabilities for both Android and iOS platforms.
                       DESC
  s.homepage         = 'https://github.com/shakilofficial0/tflite_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CodeBumble' => 'support@codebumble.net' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Add TensorFlow Lite dependencies
  s.dependency 'TensorFlowLiteSwift', '~> 2.14.0'
  s.dependency 'TensorFlowLiteTaskVision', '~> 0.4.4'
  s.dependency 'TensorFlowLiteTaskText', '~> 0.4.4'
  
  # Metal and CoreML delegates
  s.dependency 'TensorFlowLiteGpuDelegate', '~> 2.14.0'
  s.dependency 'TensorFlowLiteCoreML', '~> 2.14.0'
end