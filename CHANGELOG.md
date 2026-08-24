## 1.0.4

### Static Analysis & Example App Fixes 🧹

#### `flutter analyze` Clean-up
- **324 → 0 issues**: Resolved every warning/error reported by `flutter analyze` across the plugin and all 14 bundled example apps
- **Plugin lints**: Removed the unnecessary named `library` directive and escaped a stray `List<dynamic>` doc-comment that was being parsed as HTML
- **Deprecated API usage**: Replaced `Color.withOpacity()` with `Color.withValues(alpha: ...)` across 11 example apps
- **Missing type annotations**: Added explicit parameter types in the `reinforcement_learning` example

#### Example App Fixes
- **Broken dependency**: `object_detection_ssd_mobilenet_v2` pointed at a nonexistent `tflite_plus: ^0.10.4` on pub.dev; switched to a local `path` dependency like every other example
- **Version conflict**: `digit_classification` pinned `image: 4.0.17`, which conflicted with the plugin's own `image: ^4.1.7` requirement and blocked `pub get` entirely
- **`.gitignore` bug**: the negation patterns meant to keep placeholder `assets/models/.gitkeep` and `README.md` files tracked were missing their `!` prefix, so those directories could never actually ship; fixed the patterns and added the missing placeholders

#### Dependencies
- Bumped `ffigen` dev dependency to `^21.0.0`

---

## 1.0.3

### Enhanced Documentation & Examples 📚

#### Documentation Improvements
- **Comprehensive Examples README**: Complete rewrite of `example/README.md` with detailed documentation
  - ✅ **15+ Example Showcase**: Comprehensive catalog of all available ML examples
  - ✅ **Feature Matrix**: Detailed comparison of capabilities across Computer Vision, Audio, NLP, and Advanced AI
  - ✅ **Platform Support**: Clear platform compatibility matrix for all examples
  - ✅ **Quick Start Guide**: Step-by-step setup instructions with code examples
  - ✅ **Live Code Samples**: Ready-to-use code snippets for:
    - Image Classification with MobileNet
    - Real-time Object Detection with camera streams
    - Audio Classification with microphone input
    - Text Classification and sentiment analysis
    - Proper resource management and error handling

#### Examples Coverage
- **Computer Vision**: 10 examples (Image Classification, Object Detection, Pose Estimation, Segmentation, Style Transfer, etc.)
- **Audio Processing**: YAMNet audio classification with live stream support
- **Natural Language Processing**: Text classification and BERT Q&A examples
- **Advanced AI**: Reinforcement learning and gesture recognition demos

#### Developer Experience
- **Setup Instructions**: Detailed platform-specific configuration guides
- **Troubleshooting Section**: Common issues and solutions
- **Best Practices**: Performance optimization and resource management tips
- **Contributing Guidelines**: Clear instructions for adding new examples
- **Learning Resources**: Educational content for ML concepts and implementation patterns

#### Technical Details
- **Cross-Platform Support**: Updated compatibility information for Android, iOS, and Desktop platforms
- **Hardware Acceleration**: Documented GPU, NNAPI, Metal, and CoreML delegate usage
- **Model Management**: Guidelines for downloading and managing TensorFlow Lite models
- **Performance Optimization**: Memory usage and inference speed optimization techniques

---

## 1.0.2

### Major API Overhaul - FFI Implementation 🔄

#### Breaking Changes
- **Complete API Rewrite**: Migrated from high-level method channel API to low-level FFI-based `Interpreter` API
- **Removed Legacy API**: All `TflitePlus.*` static methods have been removed:
  - ❌ `TflitePlus.loadModel()`
  - ❌ `TflitePlus.runModelOnImage()`
  - ❌ `TflitePlus.detectObjectOnImage()`
  - ❌ `TflitePlus.runPoseNetOnImage()`
  - ❌ `TflitePlus.getAvailableDelegates()`
  - ❌ `TflitePlus.close()`

#### New Features
- **FFI Interpreter API**: Direct FFI bindings to TensorFlow Lite C++ library
  - ✅ `Interpreter.fromAsset()` - Load models from Flutter assets
  - ✅ `Interpreter.fromFile()` - Load models from file system
  - ✅ `Interpreter.fromBuffer()` - Load models from memory buffer
  - ✅ `interpreter.run()` - Single input/output inference
  - ✅ `interpreter.runForMultipleInputs()` - Multi-input/output inference
  - ✅ `interpreter.invoke()` - Raw inference execution
- **Hardware Delegates**: Platform-specific acceleration
  - ✅ `GpuDelegate` (Android)
  - ✅ `MetalDelegate` (iOS)
  - ✅ `XNNPackDelegate` (Cross-platform)
  - ✅ `CoreMLDelegate` (iOS)
- **InterpreterOptions**: Configuration for threads, delegates, and optimization
- **Direct Tensor Access**: Low-level tensor manipulation with `Tensor` class
- **Model Management**: `Model` class for advanced model operations

#### Migration Guide
```dart
// Old API (v1.0.0)
await TflitePlus.loadModel(model: 'model.tflite');
final results = await TflitePlus.runModelOnImage(path: imagePath);

// New API (v1.0.1+)
final interpreter = await Interpreter.fromAsset('model.tflite');
final input = Float32List(inputSize);
final output = List.filled(outputSize, 0.0);
interpreter.run(input, output);
interpreter.close();
```

#### Improvements
- **Performance**: Direct FFI calls eliminate method channel overhead
- **Memory Management**: Explicit resource control with `close()` method
- **Type Safety**: Strongly typed tensor operations
- **Lower-level Access**: Full control over inference pipeline
- **Cross-platform**: Unified API across Android and iOS

#### Developer Experience
- **Updated Documentation**: All examples updated to new Interpreter API
- **Complete Examples**: Real-world image classification and batch processing samples
- **Migration Support**: Clear migration path from legacy API
- **Error Handling**: Improved exception handling with specific error types

---

## 1.0.0

### Initial Release 🎉

#### Features
- **Image Classification**: Complete support for image classification using TensorFlow Lite models
- **Object Detection**: Comprehensive object detection with bounding boxes and confidence scores
- **Pose Estimation**: Human pose estimation using PoseNet models
- **Semantic Segmentation**: Pixel-level image segmentation capabilities
- **Multi-Platform Support**: Full Android and iOS compatibility
- **Hardware Acceleration**: 
  - Android: GPU delegate, NNAPI delegate
  - iOS: Metal delegate, CoreML delegate
- **Flexible Input Methods**: Support for both file paths and binary data
- **Asynchronous Operations**: Non-blocking inference with proper async/await support
- **Model Management**: Load, close, and query model information
- **Comprehensive API**: All major TensorFlow Lite operations covered

#### Platform Support
- **Android**: API level 21+ with LiteRT 2.0.2
- **iOS**: iOS 12.0+ with TensorFlow Lite Swift

#### Dependencies
- Google AI Edge LiteRT 2.0.2
- TensorFlow Lite Task Vision/Text libraries
- GPU acceleration libraries for both platforms

#### Documentation
- Comprehensive README with examples
- API documentation for all methods
- Performance optimization guides
- Troubleshooting section
- Example app with practical demonstrations

#### Developer Experience
- Type-safe Dart APIs
- Comprehensive error handling
- Detailed logging and debugging support
- Easy integration with existing Flutter apps
- Extensive customization options
