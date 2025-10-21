# TensorFlow Lite Plus

A comprehensive Flutter plugin for Google AI's LiteRT (TensorFlow Lite) with advanced machine learning capabilities for both Android and iOS platforms.

[![pub package](https://img.shields.io/pub/v/tflite_plus.svg)](https://pub.dev/packages/tflite_plus)
[![GitHub stars](https://img.shields.io/github/stars/shakilofficial0/tflite_plus.svg?style=social&label=Star)](https://github.com/shakilofficial0/tflite_plus)
[![GitHub issues](https://img.shields.io/github/issues/shakilofficial0/tflite_plus.svg)](https://github.com/shakilofficial0/tflite_plus/issues)

## Features

- 🔥 **Image Classification**: Classify images using pre-trained or custom models
- 🎯 **Object Detection**: Detect and locate objects in images with bounding boxes
- 🏃 **Pose Estimation**: Detect human poses and keypoints using PoseNet
- 🎨 **Semantic Segmentation**: Pixel-level image segmentation
- ⚡ **Hardware Acceleration**: GPU, NNAPI, Metal, and CoreML delegate support
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🔧 **Flexible Input**: Support for both file paths and binary data
- 🚀 **Asynchronous Operations**: Non-blocking inference with async/await
- 🎛️ **Configurable**: Extensive customization options for all operations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tflite_plus: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android

Add the following to your `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos for ML inference.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images for ML inference.</string>
```

Update your `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Usage

### Basic Setup

```dart
import 'package:tflite_plus/tflite_plus.dart';

// Load a model
String? result = await TflitePlus.loadModel(
  model: 'assets/models/mobilenet_v1_1.0_224.tflite',
  labels: 'assets/models/mobilenet_v1_1.0_224_labels.txt',
  numThreads: 1,
  useGpuDelegate: true, // Use GPU acceleration
);

print(result); // "Model loaded successfully"
```

### Image Classification

```dart
// Classify an image from file
List<dynamic>? results = await TflitePlus.runModelOnImage(
  path: imagePath,
  numResults: 5,
  threshold: 0.1,
  imageMean: 117.0,
  imageStd: 1.0,
);

// Classify image from binary data
List<dynamic>? results = await TflitePlus.runModelOnBinary(
  bytesList: imageBytes,
  imageHeight: 224,
  imageWidth: 224,
  numResults: 5,
  threshold: 0.1,
);

// Results format:
// [
//   {
//     "label": "Egyptian cat",
//     "confidence": 0.8203125,
//     "index": 285
//   }
// ]
```

### Object Detection

```dart
// Detect objects in an image
List<dynamic>? detections = await TflitePlus.detectObjectOnImage(
  path: imagePath,
  numResultsPerClass: 5,
  threshold: 0.3,
  imageMean: 127.5,
  imageStd: 127.5,
);

// Results format:
// [
//   {
//     "label": "person",
//     "confidence": 0.8984375,
//     "rect": {
//       "x": 0.1234,
//       "y": 0.2345,
//       "w": 0.3456,
//       "h": 0.4567
//     }
//   }
// ]
```

### Pose Estimation

```dart
// Detect human poses
List<dynamic>? poses = await TflitePlus.runPoseNetOnImage(
  path: imagePath,
  numResults: 5,
  threshold: 0.1,
  imageMean: 127.5,
  imageStd: 127.5,
);

// Results format:
// [
//   {
//     "keypoints": [
//       {
//         "x": 0.1234,
//         "y": 0.2345,
//         "part": "nose",
//         "confidence": 0.8984375
//       }
//     ]
//   }
// ]
```

### Semantic Segmentation

```dart
// Perform semantic segmentation
dynamic segmentation = await TflitePlus.runSegmentationOnImage(
  path: imagePath,
  imageMean: 127.5,
  imageStd: 127.5,
  labelColors: [
    {"r": 0, "g": 0, "b": 0},      // Background
    {"r": 255, "g": 0, "b": 0},    // Person
    {"r": 0, "g": 255, "b": 0},    // Car
  ],
  outputType: "png",
);
```

### Model Management

```dart
// Check if model is loaded
bool isLoaded = await TflitePlus.isModelLoaded();

// Get model input shape
List<int>? inputShape = await TflitePlus.getModelInputShape();
print(inputShape); // [1, 224, 224, 3]

// Get model output shape
List<int>? outputShape = await TflitePlus.getModelOutputShape();

// Get available delegates
List<String>? delegates = await TflitePlus.getAvailableDelegates();
print(delegates); // ["CPU", "GPU", "NNAPI"] on Android
                  // ["CPU", "Metal", "CoreML"] on iOS

// Close model and free resources
await TflitePlus.close();
```

## Advanced Configuration

### GPU Acceleration

```dart
// Load model with GPU delegate
await TflitePlus.loadModel(
  model: 'assets/models/model.tflite',
  useGpuDelegate: true,  // Android: GPU, iOS: Metal
  numThreads: 1,
);
```

### NNAPI/CoreML Acceleration

```dart
// Android: NNAPI, iOS: CoreML
await TflitePlus.loadModel(
  model: 'assets/models/model.tflite',
  useNnApiDelegate: true,  // Android: NNAPI, iOS: CoreML
  numThreads: 1,
);
```

### Asynchronous vs Synchronous

```dart
// Asynchronous (default, recommended)
List<dynamic>? results = await TflitePlus.runModelOnImage(
  path: imagePath,
  asynch: true,  // Default
);

// Synchronous (blocks UI thread)
List<dynamic>? results = await TflitePlus.runModelOnImage(
  path: imagePath,
  asynch: false,
);
```

## Model Formats and Compatibility

### Supported Model Types

- **Image Classification**: MobileNet, EfficientNet, ResNet, etc.
- **Object Detection**: MobileNet SSD, YOLOv5, etc.
- **Pose Estimation**: PoseNet models
- **Semantic Segmentation**: DeepLab models

### Model Optimization

For best performance, ensure your models are:

1. **Quantized**: Use TensorFlow Lite's quantization tools
2. **Optimized**: Use TensorFlow Lite Converter with optimization flags
3. **Compact**: Remove unnecessary operations and use efficient architectures

Example TensorFlow Lite conversion:

```python
import tensorflow as tf

# Convert and optimize model
converter = tf.lite.TFLiteConverter.from_saved_model('model_directory')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]  # Use FP16 for GPU
tflite_model = converter.convert()

# Save optimized model
with open('model_optimized.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Performance Tips

1. **Use GPU Acceleration**: Enable GPU delegates for faster inference
2. **Batch Processing**: Process multiple images together when possible
3. **Image Preprocessing**: Resize images to model input size before inference
4. **Model Quantization**: Use quantized models for faster inference and smaller size
5. **Thread Management**: Adjust `numThreads` based on device capabilities

## Troubleshooting

### Common Issues

**Model Loading Fails**
```dart
// Ensure model is in assets and pubspec.yaml is configured
flutter:
  assets:
    - assets/models/
```

**GPU Delegate Not Available**
```dart
// Check available delegates first
List<String>? delegates = await TflitePlus.getAvailableDelegates();
if (delegates?.contains('GPU') == true) {
  // GPU is available
}
```

**Memory Issues**
```dart
// Close model when not needed
await TflitePlus.close();

// Use smaller batch sizes
// Process images one at a time for memory-constrained devices
```

## Examples

Check out the [example app](https://github.com/shakilofficial0/tflite_plus/tree/main/example) for complete working examples of:

- Image classification with MobileNet
- Object detection with SSD MobileNet
- Pose estimation with PoseNet
- Real-time camera inference
- Custom model integration

## Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/shakilofficial0/tflite_plus/blob/main/CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/tflite_plus.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Run tests: `flutter test`
6. Submit a pull request

## Support

- 📧 Email: [support@codebumble.net](mailto:support@codebumble.net)
- 🐛 Issues: [GitHub Issues](https://github.com/shakilofficial0/tflite_plus/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/shakilofficial0/tflite_plus/discussions)
- 🌐 Website: [codebumble.net](https://codebumble.net)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Google AI for LiteRT/TensorFlow Lite
- The Flutter team for the excellent plugin architecture
- The open source community for continuous support and contributions

---

**Made with ❤️ by [CodeBumble](https://codebumble.net)**

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

The plugin project was generated without specifying the `--platforms` flag, no platforms are currently supported.
To add platforms, run `flutter create -t plugin --platforms <platforms> .` in this directory.
You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/to/pubspec-plugin-platforms.
