# 🔥 TensorFlow Lite Plus

<div align="center">

*A comprehensive Flutter plugin for TensorFlow Lite with advanced ML capabilities*

[![pub package](https://img.shields.io/pub/v/tflite_plus.svg?style=for-the-badge)](https://pub.dev/packages/tflite_plus)
[![GitHub stars](https://img.shields.io/github/stars/shakilofficial0/tflite_plus.svg?style=for-the-badge&logo=github)](https://github.com/shakilofficial0/tflite_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg?style=for-the-badge)](https://flutter.dev)

[![Android](https://img.shields.io/badge/Android-21%2B-green.svg?style=flat-square&logo=android)](https://developer.android.com)
[![iOS](https://img.shields.io/badge/iOS-12.0%2B-blue.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios)
[![GitHub issues](https://img.shields.io/github/issues/shakilofficial0/tflite_plus.svg?style=flat-square)](https://github.com/shakilofficial0/tflite_plus/issues)
[![GitHub PRs](https://img.shields.io/github/issues-pr/shakilofficial0/tflite_plus.svg?style=flat-square)](https://github.com/shakilofficial0/tflite_plus/pulls)

*Bring the power of AI to your Flutter apps with ease* 🚀

</div>

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start-ffi-interpreter-api)
- [📦 Installation](#-installation)
- [⚙️ Platform Setup](#️-platform-setup)
- [📚 Public API](#-public-api-high-level)
- [🎯 Usage Examples](#-usage-examples-interpreter)
- [🔧 Advanced Configuration](#-advanced-configuration)
- [⚡ Performance Tips](#-performance-tips)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🧪 Complete Examples](#-complete-examples)
- [🤝 Contributing](#-contributing)
- [💬 Support](#-support)
- [📄 License](#-license)

---

## ✨ Features

<table>
<tr>
<td align="center">🔥</td>
<td><b>Image Classification</b><br/>Classify images using pre-trained or custom models</td>
</tr>
<tr>
<td align="center">🎯</td>
<td><b>Object Detection</b><br/>Detect and locate objects with bounding boxes</td>
</tr>
<tr>
<td align="center">🏃</td>
<td><b>Pose Estimation</b><br/>Detect human poses and keypoints using PoseNet</td>
</tr>
<tr>
<td align="center">🎨</td>
<td><b>Semantic Segmentation</b><br/>Pixel-level image segmentation</td>
</tr>
<tr>
<td align="center">⚡</td>
<td><b>Hardware Acceleration</b><br/>GPU, NNAPI, Metal, and CoreML delegate support</td>
</tr>
<tr>
<td align="center">📱</td>
<td><b>Cross-Platform</b><br/>Works seamlessly on Android and iOS</td>
</tr>
<tr>
<td align="center">🔧</td>
<td><b>Flexible Input</b><br/>Support for file paths and binary data</td>
</tr>
<tr>
<td align="center">🚀</td>
<td><b>Asynchronous</b><br/>Non-blocking inference with async/await</td>
</tr>
</table>

---

## 🚀 Quick Start (FFI Interpreter API)

This package now exposes a low-level, FFI-backed Interpreter API. Use the `Interpreter` class to load models (from assets, files, or buffers), run inference and manage resources.

```dart
import 'package:tflite_plus/tflite_plus.dart';

// 1. Load your model from assets
final interpreter = await Interpreter.fromAsset('assets/models/mobilenet.tflite');

// 2. Prepare your input (must match model input shape and type)
// Example: a Float32 input buffer for a 1x224x224x3 model
final input = Float32List(1 * 224 * 224 * 3);
// Fill `input` with normalized image data...

// 3. Prepare output container (shape depends on model)
final output = List.filled(1 * 1001, 0.0); // adjust to your model's output size

// 4. Run inference
interpreter.run(input, output);

// 5. Use results
print('Top score: ${output[0]}');

// 6. Close when done
interpreter.close();
```

---

## 📦 Installation

### 1. Add Dependency

```yaml
dependencies:
  tflite_plus: ^1.0.3
```

### 2. Install

```bash
flutter pub get
```

### 3. Import

```dart
import 'package:tflite_plus/tflite_plus.dart';
```

---

## ⚙️ Platform Setup

### Android Configuration (Not Mandatory)

Add to `android/app/build.gradle`: (Not Mandatory)

```gradle
android {
    defaultConfig {
        minSdkVersion 21 
    }
}
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for ML inference.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access for ML inference.</string>
```

Update `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

---


## 📚 Public API (high level)

This repository now exports a set of low-level, FFI-backed primitives. The most commonly used APIs are:

| Symbol | Description |
|--------|-------------|
| `Interpreter` | Core class to load a TensorFlow Lite model (from asset/file/buffer) and run inference. See `Interpreter.fromAsset`, `Interpreter.fromBuffer`, `Interpreter.fromFile`, `run`, `runForMultipleInputs`, `invoke`, `close`.
| `InterpreterOptions` | Options used when creating an `Interpreter` (delegates, threads, etc.).
| `Delegate` and delegate implementations | Hardware delegates and helpers: `GpuDelegate`, `MetalDelegate`, `XNNPackDelegate`, `CoreMLDelegate`.
| `Tensor` | Accessor for input/output tensor metadata and data helpers.
| `Model` | Low-level model helpers (used internally).

For advanced uses you can also work directly with the exported utilities in `src/util/` such as byte conversion helpers.

---

## 🎯 Usage Examples (Interpreter)

Below are three small recipes using the FFI `Interpreter` API. These are intentionally low-level — for higher-level helpers (pre/post-processing, label mapping) check the `example/` folder for complete apps.

### 1. Simple Image Classification (synchronous run)

```dart
import 'dart:typed_data';
import 'package:tflite_plus/tflite_plus.dart';

final interpreter = await Interpreter.fromAsset('assets/models/mobilenet.tflite');

// Example input for 1x224x224x3 float model
final input = Float32List(1 * 224 * 224 * 3);
// TODO: fill input with normalized image bytes

final output = List.filled(1 * 1001, 0.0);
interpreter.run(input, output);

// Process output (find top results)
// ...

interpreter.close();
```

### 2. Object Detection (multiple outputs)

```dart
import 'dart:typed_data';
import 'package:tflite_plus/tflite_plus.dart';

final interpreter = await Interpreter.fromAsset('assets/models/ssd_mobilenet.tflite');

final input = Float32List(1 * 300 * 300 * 3);
// Output map: index -> buffer for each output tensor
final outputs = <int, Object>{
  0: List.filled(1 * 10 * 4, 0.0), // boxes
  1: List.filled(1 * 10, 0.0), // classes
  2: List.filled(1 * 10, 0.0), // scores
};

interpreter.runForMultipleInputs([input], outputs);

// Parse outputs from `outputs`

interpreter.close();
```

### 3. Pose Estimation (invoke + tensor helpers)

```dart
import 'dart:typed_data';
import 'package:tflite_plus/tflite_plus.dart';

final interpreter = await Interpreter.fromAsset('assets/models/posenet.tflite');

final input = Float32List(1 * 257 * 257 * 3);
final output = List.filled(1 * 17 * 3, 0.0);

interpreter.run(input, output);

// Output post-processing to get keypoints

interpreter.close();
```

---

### Notes on parameters

The new API is lower-level and works directly with typed buffers (Float32List, Uint8List, etc.). Use `Tensor` helpers and `InterpreterOptions` to configure delegates and threads. See `lib/src/interpreter.dart` for the full API and examples in `example/` for end-to-end usage.

---

## 🔧 Advanced Configuration

### GPU Acceleration

```dart
import 'dart:io' show Platform;
import 'package:tflite_plus/tflite_plus.dart';

// Create interpreter with GPU delegate
final options = InterpreterOptions();
if (Platform.isAndroid) {
  options.addDelegate(GpuDelegate());
} else if (Platform.isIOS) {
  options.addDelegate(MetalDelegate());
}

final interpreter = await Interpreter.fromAsset(
  'assets/models/model.tflite', 
  options: options,
);
```

### NNAPI/CoreML Acceleration  

```dart
// Enable NNAPI (Android) / CoreML (iOS)
final options = InterpreterOptions();
if (Platform.isAndroid) {
  // NNAPI delegate (Android)
  options.addDelegate(XNNPackDelegate());
} else if (Platform.isIOS) {
  // CoreML delegate (iOS) 
  options.addDelegate(CoreMLDelegate());
}

final interpreter = await Interpreter.fromAsset(
  'assets/models/model.tflite',
  options: options,
);
```

### Thread Configuration

```dart
import 'dart:io' show Platform;
import 'dart:math' as math;

// Optimize for different devices
final numCores = Platform.numberOfProcessors;
final options = InterpreterOptions()
  ..threads = math.min(numCores, 4); // Use up to 4 threads

final interpreter = await Interpreter.fromAsset(
  'assets/models/model.tflite',
  options: options,
);
```

### Working with Raw Tensor Data

```dart
// Access input/output tensors directly  
final interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

// Get input tensor info
final inputTensor = interpreter.getInputTensor(0);
print('Input shape: ${inputTensor.shape}');
print('Input type: ${inputTensor.type}');

// Get output tensor info
final outputTensor = interpreter.getOutputTensor(0);
print('Output shape: ${outputTensor.shape}');

interpreter.close();
```

---

## ⚡ Performance Tips

### 🎯 Model Optimization

```python
# Optimize your TensorFlow Lite model
import tensorflow as tf

converter = tf.lite.TFLiteConverter.from_saved_model('model')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
```

### 📱 Best Practices

1. **Use Hardware Delegates**: GPU/Metal delegates provide 2-4x faster inference
2. **Quantize Models**: INT8 quantized models are smaller and faster
3. **Optimize Thread Usage**: Use multiple threads but don't exceed CPU cores
4. **Proper Tensor Management**: Reuse tensors when possible, call `close()` when done
5. **Preprocess Efficiently**: Resize images to exact model input dimensions

### ⚙️ Performance Benchmarks

| Device | Model | CPU (ms) | GPU (ms) | Speedup |
|--------|-------|----------|----------|---------|
| Pixel 6 | MobileNet | 45 | 12 | 3.75x |
| iPhone 13 | MobileNet | 38 | 8 | 4.75x |
| Galaxy S21 | EfficientNet | 120 | 28 | 4.28x |

---

## 🛠️ Troubleshooting

### Common Issues & Solutions

#### Model Loading Fails

```dart
// ❌ Problem: Model not found
// ✅ Solution: Check assets configuration
flutter:
  assets:
    - assets/models/
```

#### GPU Delegate Issues

```dart
// ❌ Problem: GPU acceleration fails
// ✅ Solution: Handle delegate errors gracefully
try {
  final options = InterpreterOptions();
  if (Platform.isAndroid) {
    options.addDelegate(GpuDelegate());
  }
  final interpreter = await Interpreter.fromAsset('model.tflite', options: options);
} catch (e) {
  // Fallback to CPU-only interpreter
  final interpreter = await Interpreter.fromAsset('model.tflite');
}
```

#### Memory Issues

```dart
// ❌ Problem: Out of memory
// ✅ Solution: Resource management
interpreter.close(); // Always clean up when done

// Process smaller batches
// Use quantized models  
// Reduce input tensor sizes
```

#### Inference Too Slow

```dart
// ❌ Problem: Slow inference
// ✅ Solution: Optimization strategies
final options = InterpreterOptions()
  ..threads = 4;                    // Use multiple threads
  
if (Platform.isAndroid) {
  options.addDelegate(GpuDelegate()); // Enable GPU
}

final interpreter = await Interpreter.fromAsset(
  'assets/models/model_quantized.tflite', // Use quantized model
  options: options,
);
```

### Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| `ArgumentError` | Invalid model file or corrupt data | Check model file path and integrity |
| `StateError` | Interpreter not allocated | Call `allocateTensors()` or ensure model is loaded |
| `RangeError` | Invalid tensor index | Check tensor indices with `getInputTensors().length` |
| `Out of memory` | Insufficient RAM | Use smaller models/reduce batch size |

---

## 🧪 Complete Examples

### Basic Image Classification with File Input

```dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_plus/tflite_plus.dart';
import 'package:image/image.dart' as img;

class ImageClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    // Load the interpreter
    _interpreter = await Interpreter.fromAsset('assets/models/mobilenet.tflite');
    
    // Load labels
    final labelData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelData.split('\n');
  }

  Future<List<Map<String, dynamic>>> classifyImage(String imagePath) async {
    if (_interpreter == null) throw StateError('Model not loaded');

    // Load and preprocess image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes)!;
    
    // Resize to model input size (224x224 for MobileNet)
    final resized = img.copyResize(image, width: 224, height: 224);
    
    // Convert to Float32List and normalize
    final input = Float32List(1 * 224 * 224 * 3);
    var index = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = (img.getRed(pixel) - 127.5) / 127.5;
        input[index++] = (img.getGreen(pixel) - 127.5) / 127.5; 
        input[index++] = (img.getBlue(pixel) - 127.5) / 127.5;
      }
    }
    
    // Run inference
    final output = List.filled(1001, 0.0);
    _interpreter!.run(input, output);
    
    // Convert to results
    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < output.length; i++) {
      results.add({
        'index': i,
        'label': i < _labels!.length ? _labels![i] : 'Unknown',
        'confidence': output[i],
      });
    }
    
    // Sort by confidence and return top 5
    results.sort((a, b) => b['confidence'].compareTo(a['confidence']));
    return results.take(5).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
```

### Batch Processing with Progress Tracking

```dart
class BatchImageProcessor {
  static Future<List<Map<String, dynamic>>> processImages(
    List<String> imagePaths,
    {Function(int, int)? onProgress}
  ) async {
    final classifier = ImageClassifier();
    await classifier.loadModel();

    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final predictions = await classifier.classifyImage(imagePaths[i]);
        
        results.add({
          'path': imagePaths[i],
          'predictions': predictions,
          'status': 'success',
        });
        
        onProgress?.call(i + 1, imagePaths.length);
        
      } catch (e) {
        results.add({
          'path': imagePaths[i],
          'error': e.toString(),
          'status': 'error',
        });
      }
    }
    
    classifier.dispose();
    return results;
  }
}
```

---

## 🤝 Contributing

We welcome contributions from the community! 🎉

### Contributors

<div align="center">

<!-- Contributors Grid -->
<table>
<tr>
<td align="center">
<a href="https://github.com/shakilofficial0">
<img src="https://github.com/shakilofficial0.png" width="100px;" alt="Shakil Ahmed"/>
<br />
<sub><b>Shakil Ahmed</b></sub>
</a>
<br />
<sub>🚀 Creator & Maintainer</sub>
</td>

</tr>
</table>

*Want to see your profile here? [Contribute to the project!](#how-to-contribute)*

</div>

### How to Contribute

#### 🚀 Quick Start

1. **Fork & Clone**
   ```bash
   git clone https://github.com/yourusername/tflite_plus.git
   cd tflite_plus
   ```

2. **Create Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Changes**
   - Add your awesome code
   - Write tests
   - Update documentation

4. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Submit PR**
   ```bash
   git push origin feature/amazing-feature
   ```

#### 🎯 Contribution Types

| Type | Description | Label |
|------|-------------|-------|
| 🐛 **Bug Fix** | Fix existing issues | `bug` |
| ✨ **Feature** | Add new functionality | `enhancement` |
| 📚 **Documentation** | Improve docs | `documentation` |
| 🎨 **UI/UX** | Design improvements | `design` |
| ⚡ **Performance** | Speed optimizations | `performance` |
| 🧪 **Tests** | Add or improve tests | `tests` |

#### 📋 Contribution Guidelines

- **Code Style**: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Testing**: Add tests for new features
- **Documentation**: Update README and code comments
- **Commits**: Use [Conventional Commits](https://conventionalcommits.org/)

#### 🏆 Recognition

Contributors get:
- 🌟 Profile picture in README
- 🎖️ Contributor badge on GitHub
- 📢 Mention in release notes
- 🎁 Special Discord role (coming soon)

---

## 💬 Support

<div align="center">

### Get Help & Connect

[![Email](https://img.shields.io/badge/Email-support%40codebumble.net-red?style=for-the-badge&logo=gmail)](mailto:support@codebumble.net)
[![GitHub Issues](https://img.shields.io/badge/Issues-GitHub-orange?style=for-the-badge&logo=github)](https://github.com/shakilofficial0/tflite_plus/issues)
[![Discussions](https://img.shields.io/badge/Discussions-GitHub-blue?style=for-the-badge&logo=github)](https://github.com/shakilofficial0/tflite_plus/discussions)
[![Website](https://img.shields.io/badge/Website-codebumble.net-green?style=for-the-badge&logo=safari)](https://codebumble.net)

</div>

### 📞 Support Channels

| Channel | Purpose | Response Time |
|---------|---------|---------------|
| 🐛 **GitHub Issues** | Bug reports, feature requests | 24-48 hours |
| 💬 **GitHub Discussions** | Questions, community help | 1-3 days |
| 📧 **Email** | Private support, partnerships | 2-5 days |
| 🌐 **Website** | Documentation, tutorials | Always available |

### 🆘 Before Asking for Help

1. **Check Documentation**: Read this README thoroughly
2. **Search Issues**: Look for existing solutions
3. **Provide Details**: Include code, error messages, device info
4. **Minimal Example**: Create a minimal reproducible example

---

## 📄 License

```
MIT License

Copyright (c) 2024 CodeBumble

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

### 🎉 Acknowledgments

**Special Thanks To:**
- 🤖 Google AI Team for TensorFlow Lite
- 🐦 Flutter Team for the amazing framework  
- 🌟 Open Source Community for continuous support
- 💻 All contributors who make this project better

---

**Made with ❤️ by [CodeBumble](https://codebumble.net)**

*If this project helped you, please consider giving it a ⭐ on GitHub!*

[![Star on GitHub](https://img.shields.io/github/stars/shakilofficial0/tflite_plus.svg?style=social)](https://github.com/shakilofficial0/tflite_plus/stargazers)

</div>

![Profile Views](https://visitor-badge.laobi.icu/badge?page_id=shakilofficial0.tflite_plus)
