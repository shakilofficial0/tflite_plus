# 🚀 TensorFlow Lite Plus Examples

<div align="center">

*Comprehensive examples showcasing the power of TensorFlow Lite in Flutter*

[![pub package](https://img.shields.io/pub/v/tflite_plus.svg?style=for-the-badge)](https://pub.dev/packages/tflite_plus)
[![GitHub stars](https://img.shields.io/github/stars/shakilofficial0/tflite_plus.svg?style=for-the-badge&logo=github)](https://github.com/shakilofficial0/tflite_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*Ready-to-run examples for AI-powered Flutter apps* 🤖

</div>

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🔧 What TensorFlow Lite Plus Can Do](#-what-tensorflow-lite-plus-can-do)
- [📱 Available Examples](#-available-examples)
- [🚀 Quick Start](#-quick-start)
- [🏗️ Setup Instructions](#️-setup-instructions)
- [💡 Usage Examples](#-usage-examples)
- [🌐 Platform Support](#-platform-support)
- [📚 Learning Resources](#-learning-resources)
- [🤝 Contributing](#-contributing)

---

## 🎯 Overview

This folder contains **15+ comprehensive examples** demonstrating how to use the `tflite_plus` plugin for various AI/ML tasks in Flutter applications. Each example is a complete, runnable app that showcases different aspects of machine learning on mobile devices.

The **TensorFlow Lite Plus** plugin brings Google AI's LiteRT (TensorFlow Lite) to Flutter with advanced capabilities, hardware acceleration, and cross-platform support.

---

## 🔧 What TensorFlow Lite Plus Can Do

<table>
<tr>
<td align="center">🖼️</td>
<td><b>Image Classification</b><br/>Classify images using pre-trained models like MobileNet, EfficientNet, or your custom models</td>
</tr>
<tr>
<td align="center">🎯</td>
<td><b>Object Detection</b><br/>Detect and locate multiple objects with bounding boxes using SSD MobileNet</td>
</tr>
<tr>
<td align="center">🏃‍♂️</td>
<td><b>Pose Estimation</b><br/>Real-time human pose detection and keypoint tracking using PoseNet</td>
</tr>
<tr>
<td align="center">🎨</td>
<td><b>Image Segmentation</b><br/>Pixel-level semantic segmentation for detailed image understanding</td>
</tr>
<tr>
<td align="center">🎵</td>
<td><b>Audio Classification</b><br/>Classify audio events and sounds using YAMNet and other audio models</td>
</tr>
<tr>
<td align="center">📝</td>
<td><b>Text Classification</b><br/>Sentiment analysis and text categorization with NLP models</td>
</tr>
<tr>
<td align="center">🎭</td>
<td><b>Style Transfer</b><br/>Apply artistic styles to images using neural style transfer</td>
</tr>
<tr>
<td align="center">🔍</td>
<td><b>Super Resolution</b><br/>Enhance image quality with ESRGAN super-resolution models</td>
</tr>
<tr>
<td align="center">🤖</td>
<td><b>BERT Q&A</b><br/>Question answering using BERT models for natural language understanding</td>
</tr>
<tr>
<td align="center">✋</td>
<td><b>Gesture Recognition</b><br/>Recognize hand gestures and finger movements in real-time</td>
</tr>
<tr>
<td align="center">🔢</td>
<td><b>Digit Classification</b><br/>Handwritten digit recognition using CNN models</td>
</tr>
<tr>
<td align="center">🎮</td>
<td><b>Reinforcement Learning</b><br/>Interactive AI agents using reinforcement learning models</td>
</tr>
</table>

### 🚀 Key Features

- **Hardware Acceleration**: GPU, NNAPI, Metal, and CoreML delegate support
- **Cross-Platform**: Works on Android, iOS, Linux, macOS, and Windows
- **Real-time Processing**: Live camera stream analysis and processing
- **Multiple Input Types**: Support for images, audio, text, and binary data
- **Asynchronous Operations**: Non-blocking inference with async/await
- **Custom Model Support**: Load your own trained TensorFlow Lite models
- **Performance Optimized**: Efficient memory usage and fast inference times

---

## 📱 Available Examples

### 🖼️ Computer Vision

| Example | Description | Platforms | Live Stream |
|---------|-------------|-----------|-------------|
| **[Image Classification MobileNet](./image_classification_mobilenet/)** | Classify objects in images using MobileNet | Android, iOS, Desktop | ✅ |
| **[Object Detection SSD MobileNet](./object_detection_ssd_mobilenet/)** | Detect multiple objects with bounding boxes | Android, iOS, Desktop | ✅ |
| **[Object Detection SSD MobileNet V2](./object_detection_ssd_mobilenet_v2/)** | Enhanced object detection with improved accuracy | Android, iOS, Desktop | ✅ |
| **[Live Object Detection](./live_object_detection_ssd_mobilenet/)** | Real-time object detection from camera feed | Android, iOS | ✅ |
| **[Pose Estimation](./pose_estimation/)** | Human pose detection and keypoint tracking | Android, iOS | ✅ |
| **[Image Segmentation](./image_segmentation/)** | Pixel-level semantic segmentation | Android, iOS, Desktop | ❌ |
| **[Style Transfer](./style_transfer/)** | Apply artistic styles to images | Android, iOS, Desktop | ❌ |
| **[Super Resolution ESRGAN](./super_resolution_esrgan/)** | Enhance image quality with AI upscaling | Android, iOS, Desktop | ❌ |
| **[Gesture Classification](./gesture_classification/)** | Hand gesture recognition | Android, iOS, Desktop | ✅ |
| **[Digit Classification](./digit_classification/)** | Handwritten digit recognition | Android, iOS, Desktop | ❌ |

### 🎵 Audio Processing

| Example | Description | Platforms | Live Stream |
|---------|-------------|-----------|-------------|
| **[Audio Classification YAMNet](./audio_classification/)** | Real-time audio event classification | Android, iOS | ✅ |

### 📝 Natural Language Processing

| Example | Description | Platforms | Live Stream |
|---------|-------------|-----------|-------------|
| **[Text Classification](./text_classification/)** | Sentiment analysis and text categorization | All Platforms | ❌ |
| **[BERT Q&A](./bertqa/)** | Question answering using BERT models | Android, iOS, Desktop | ❌ |

### 🎮 Advanced AI

| Example | Description | Platforms | Live Stream |
|---------|-------------|-----------|-------------|
| **[Reinforcement Learning](./reinforcement_learning/)** | Interactive AI agents and game playing | Android, iOS, Desktop | ❌ |

---

## 🚀 Quick Start

### 1. Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.9.2)
- Android Studio / Xcode for mobile development
- Git for cloning repositories

### 2. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/shakilofficial0/tflite_plus.git
cd tflite_plus/example

# Choose an example (e.g., image classification)
cd image_classification_mobilenet

# Install dependencies
flutter pub get

# Download required models and labels
sh ./scripts/download_model.sh  # On Unix systems
# or
.\scripts\download_model.bat    # On Windows
```

### 3. Run the Example

```bash
# Run on connected device or emulator
flutter run

# Or run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

---

## 🏗️ Setup Instructions

### Common Setup Steps

1. **Add Dependency**: Each example already includes the `tflite_plus` dependency in `pubspec.yaml`

```yaml
dependencies:
  tflite_plus: ^1.0.3
```

2. **Download Models**: Most examples require downloading pre-trained models:

```bash
# Navigate to example folder
cd example/[example_name]

# Run download script
sh ./scripts/download_model.sh     # Unix/Mac
.\scripts\download_model.bat       # Windows
```

3. **Platform Configuration**: Some examples may require platform-specific setup (automatically handled by the plugin)

### Android Setup (Not Mandatory)

```kotlin
// android/app/build.gradle (Not Mandatory)
android {
    defaultConfig {
        minSdkVersion 21  // Minimum required (Not Mandatory)
    }
}
```

### iOS Setup

```ruby
# ios/Podfile
platform :ios, '12.0'  # Minimum required
```

---

## 💡 Usage Examples

### Basic Image Classification

```dart
import 'package:tflite_plus/tflite_plus.dart';

class ImageClassifier {
  late Interpreter interpreter;
  
  Future<void> loadModel() async {
    // Load model from assets
    interpreter = await Interpreter.fromAsset(
      'assets/models/mobilenet_v1_1.0_224.tflite'
    );
  }
  
  Future<List<double>> classifyImage(Uint8List imageBytes) async {
    // Preprocess image to model input format
    final input = preprocessImage(imageBytes);
    
    // Prepare output buffer
    final output = List.filled(1001, 0.0);
    
    // Run inference
    interpreter.run(input, output);
    
    return output;
  }
  
  Float32List preprocessImage(Uint8List imageBytes) {
    // Convert image to required format (224x224x3 for MobileNet)
    // Normalize pixel values to [-1, 1] or [0, 1] range
    // Return as Float32List
  }
}
```

### Real-time Object Detection

```dart
import 'package:camera/camera.dart';
import 'package:tflite_plus/tflite_plus.dart';

class ObjectDetector {
  late Interpreter interpreter;
  
  Future<void> initializeDetection() async {
    interpreter = await Interpreter.fromAsset(
      'assets/models/ssd_mobilenet.tflite'
    );
  }
  
  Future<List<Detection>> detectObjects(CameraImage image) async {
    // Convert camera image to model input format
    final input = convertCameraImage(image);
    
    // Prepare output tensors for SSD MobileNet
    final locations = List.filled(1 * 10 * 4, 0.0);     // Bounding boxes
    final classes = List.filled(1 * 10, 0.0);           // Class IDs
    final scores = List.filled(1 * 10, 0.0);            // Confidence scores
    final numDetections = List.filled(1, 0.0);          // Number of detections
    
    // Run inference
    interpreter.runForMultipleInputsOutputs(
      [input],
      {
        0: locations,
        1: classes, 
        2: scores,
        3: numDetections,
      }
    );
    
    return parseDetections(locations, classes, scores, numDetections[0]);
  }
}
```

### Audio Classification

```dart
import 'package:tflite_plus/tflite_plus.dart';
import 'package:record/record.dart';

class AudioClassifier {
  late Interpreter interpreter;
  final record = Record();
  
  Future<void> startAudioClassification() async {
    interpreter = await Interpreter.fromAsset('assets/models/yamnet.tflite');
    
    // Start recording
    await record.start(
      encoder: AudioEncoder.wav,
      samplingRate: 16000,
    );
    
    // Process audio in chunks
    Timer.periodic(Duration(milliseconds: 500), (timer) async {
      final audioData = await getAudioChunk();
      final predictions = await classifyAudio(audioData);
      handlePredictions(predictions);
    });
  }
  
  Future<List<double>> classifyAudio(Float32List audioData) async {
    final output = List.filled(521, 0.0); // YAMNet output size
    interpreter.run(audioData, output);
    return output;
  }
}
```

### Text Classification

```dart
import 'package:tflite_plus/tflite_plus.dart';

class TextClassifier {
  late Interpreter interpreter;
  
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset(
      'assets/models/text_classification.tflite'
    );
  }
  
  Future<Map<String, double>> classifyText(String text) async {
    // Tokenize and encode text
    final input = tokenizeText(text);
    
    // Run inference
    final output = List.filled(2, 0.0); // Binary classification
    interpreter.run(input, output);
    
    return {
      'positive': output[1],
      'negative': output[0],
    };
  }
  
  Int32List tokenizeText(String text) {
    // Convert text to tokens using your tokenizer
    // Return as Int32List matching model input shape
  }
}
```

---

## 🌐 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Full Support | Minimum API 21, NNAPI acceleration available |
| **iOS** | ✅ Full Support | iOS 12.0+, Metal and CoreML acceleration |
| **Windows** | ✅ Desktop Support | Limited camera support for live stream |
| **macOS** | ✅ Desktop Support | Limited camera support for live stream |
| **Linux** | ✅ Desktop Support | Limited camera support for live stream |
| **Web** | ❌ Not Supported | TensorFlow Lite FFI limitations |

### Feature Support Matrix

| Feature | Android | iOS | Desktop |
|---------|---------|-----|---------|
| File-based Inference | ✅ | ✅ | ✅ |
| Live Camera Stream | ✅ | ✅ | 🚧 Limited |
| Hardware Acceleration | ✅ NNAPI | ✅ Metal/CoreML | ❌ |
| Background Processing | ✅ | ✅ | ✅ |
| Custom Models | ✅ | ✅ | ✅ |

---

## 📚 Learning Resources

### Example-Specific Guides

Each example folder contains:
- **README.md**: Detailed setup and usage instructions
- **screenshots/**: Visual examples of the app in action  
- **scripts/**: Helper scripts for model downloading
- **lib/**: Complete, documented source code
- **assets/**: Required model files and test data

### Key Concepts

1. **Model Loading**: Learn how to load TensorFlow Lite models from assets or files
2. **Input Preprocessing**: Understand how to prepare data for different model types
3. **Inference Execution**: Master synchronous and asynchronous inference patterns
4. **Output Postprocessing**: Parse and utilize model predictions effectively
5. **Performance Optimization**: Implement efficient memory management and threading

### Best Practices

- Always run inference in background isolates for smooth UI
- Preprocess inputs to match exact model requirements
- Handle model loading errors gracefully
- Use appropriate data types (Float32List, Int32List, etc.)
- Implement proper resource disposal to prevent memory leaks

---

## 🛠️ Troubleshooting

### Common Issues

**Model Loading Fails**
```dart
// Ensure model is in assets and pubspec.yaml is configured
flutter:
  assets:
    - assets/models/
```

**Input Shape Mismatch**
```dart
// Check model input requirements
final inputDetails = interpreter.getInputTensors();
print('Expected shape: ${inputDetails[0].shape}');
print('Expected type: ${inputDetails[0].type}');
```

**Performance Issues**
```dart
// Use hardware acceleration when available
final interpreterOptions = InterpreterOptions()
  ..addDelegate(GpuDelegate());
  
final interpreter = await Interpreter.fromAsset(
  'model.tflite',
  options: interpreterOptions,
);
```

### Getting Help

- Check individual example READMEs for specific guidance
- Review the main [tflite_plus documentation](https://github.com/shakilofficial0/tflite_plus)
- Open issues on [GitHub](https://github.com/shakilofficial0/tflite_plus/issues)
- Join discussions in the Flutter community

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding New Examples

1. Fork the repository
2. Create a new example folder following the existing structure
3. Include comprehensive documentation and screenshots
4. Add model download scripts
5. Test on multiple platforms
6. Submit a pull request

### Improving Existing Examples

- Enhance documentation and comments
- Add new features or use cases
- Optimize performance
- Fix bugs and improve error handling
- Add support for additional platforms

### Example Structure Template

```
new_example/
├── README.md              # Comprehensive documentation
├── pubspec.yaml          # Dependencies and configuration
├── lib/                  # Source code
│   ├── main.dart
│   └── ...
├── assets/               # Models and test data
├── scripts/              # Download and setup scripts
├── screenshots/          # Visual examples
└── test/                # Unit and widget tests
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

## 🎉 Get Started Today!

Choose an example that matches your use case and start building AI-powered Flutter apps in minutes:

- 🚀 **Beginners**: Start with [Image Classification](./image_classification_mobilenet/)
- 🎯 **Computer Vision**: Try [Object Detection](./object_detection_ssd_mobilenet/)
- 🎵 **Audio AI**: Explore [Audio Classification](./audio_classification/)
- 📝 **Text AI**: Check out [Text Classification](./text_classification/)
- 🤖 **Advanced**: Dive into [BERT Q&A](./bertqa/) or [Reinforcement Learning](./reinforcement_learning/)

**Happy coding!** 🎉

---

<div align="center">

*Made with ❤️ by the TensorFlow Lite Plus community*

[⭐ Star us on GitHub](https://github.com/shakilofficial0/tflite_plus) | [📦 View on pub.dev](https://pub.dev/packages/tflite_plus) | [🐛 Report Issues](https://github.com/shakilofficial0/tflite_plus/issues)

</div>