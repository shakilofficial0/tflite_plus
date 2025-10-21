# API Documentation

## Core Classes

### TflitePlus

The main class for TensorFlow Lite operations.

#### Static Methods

##### loadModel
```dart
static Future<String?> loadModel({
  required String model,
  String? labels,
  int numThreads = 1,
  bool isAsset = true,
  bool useGpuDelegate = false,
  bool useNnApiDelegate = false,
})
```

Loads a TensorFlow Lite model.

**Parameters:**
- `model`: Path to the .tflite model file
- `labels`: Optional path to labels file
- `numThreads`: Number of threads to use (default: 1)
- `isAsset`: Whether the model is in assets (default: true)
- `useGpuDelegate`: Use GPU acceleration (default: false)
- `useNnApiDelegate`: Use NNAPI on Android/CoreML on iOS (default: false)

**Returns:** Success message or null

##### detectObjectOnImage
```dart
static Future<List<dynamic>?> detectObjectOnImage({
  required String path,
  double imageMean = 127.5,
  double imageStd = 127.5,
  int numResultsPerClass = 5,
  double threshold = 0.1,
  bool asynch = true,
})
```

Runs object detection on an image.

**Parameters:**
- `path`: Path to the image file
- `imageMean`: Image mean for normalization (default: 127.5)
- `imageStd`: Image standard deviation for normalization (default: 127.5)
- `numResultsPerClass`: Maximum results per class (default: 5)
- `threshold`: Confidence threshold (default: 0.1)
- `asynch`: Run asynchronously (default: true)

**Returns:** List of detected objects with bounding boxes

##### runModelOnImage
```dart
static Future<List<dynamic>?> runModelOnImage({
  required String path,
  int numResults = 5,
  double threshold = 0.1,
  double imageMean = 117.0,
  double imageStd = 1.0,
  bool asynch = true,
})
```

Runs image classification on an image.

**Parameters:**
- `path`: Path to the image file
- `numResults`: Maximum number of results (default: 5)
- `threshold`: Confidence threshold (default: 0.1)
- `imageMean`: Image mean for normalization (default: 117.0)
- `imageStd`: Image standard deviation for normalization (default: 1.0)
- `asynch`: Run asynchronously (default: true)

**Returns:** List of classification results

##### runPoseNetOnImage
```dart
static Future<List<dynamic>?> runPoseNetOnImage({
  required String path,
  int numResults = 5,
  double threshold = 0.1,
  double imageMean = 127.5,
  double imageStd = 127.5,
  bool asynch = true,
})
```

Runs pose estimation on an image.

**Parameters:**
- `path`: Path to the image file
- `numResults`: Maximum number of poses (default: 5)
- `threshold`: Confidence threshold (default: 0.1)
- `imageMean`: Image mean for normalization (default: 127.5)
- `imageStd`: Image standard deviation for normalization (default: 127.5)
- `asynch`: Run asynchronously (default: true)

**Returns:** List of detected poses with keypoints

##### runSegmentationOnImage
```dart
static Future<dynamic> runSegmentationOnImage({
  required String path,
  double imageMean = 127.5,
  double imageStd = 127.5,
  List<Map<String, int>>? labelColors,
  String outputType = "png",
  bool asynch = true,
})
```

Runs semantic segmentation on an image.

**Parameters:**
- `path`: Path to the image file
- `imageMean`: Image mean for normalization (default: 127.5)
- `imageStd`: Image standard deviation for normalization (default: 127.5)
- `labelColors`: Colors for different labels
- `outputType`: Output format (default: "png")
- `asynch`: Run asynchronously (default: true)

**Returns:** Segmentation result

##### close
```dart
static Future<void> close()
```

Closes the loaded model and frees resources.

##### getModelInputShape
```dart
static Future<List<int>?> getModelInputShape()
```

Gets the input shape of the loaded model.

**Returns:** Input tensor shape [batch, height, width, channels]

##### getModelOutputShape
```dart
static Future<List<int>?> getModelOutputShape()
```

Gets the output shape of the loaded model.

**Returns:** Output tensor shape

##### isModelLoaded
```dart
static Future<bool> isModelLoaded()
```

Checks if a model is currently loaded.

**Returns:** True if model is loaded, false otherwise

##### getAvailableDelegates
```dart
static Future<List<String>?> getAvailableDelegates()
```

Gets available hardware acceleration delegates.

**Returns:** List of available delegates (CPU, GPU, NNAPI, Metal, CoreML)

## Model Classes

### Recognition
Represents a classification result.

**Properties:**
- `String? label`: The classification label
- `double? confidence`: The confidence score (0.0 to 1.0)
- `int? index`: The index of the recognized class

### Detection
Represents a detected object.

**Properties:**
- `BoundingBox boundingBox`: The bounding box of the object
- `String? label`: The classification label
- `double? confidence`: The confidence score (0.0 to 1.0)
- `int? detectedClass`: The index of the detected class

### BoundingBox
Represents a bounding box for detected objects.

**Properties:**
- `double x`: X coordinate of the top-left corner
- `double y`: Y coordinate of the top-left corner
- `double width`: Width of the bounding box
- `double height`: Height of the bounding box

### Pose
Represents a detected pose.

**Properties:**
- `List<Keypoint> keypoints`: List of keypoints that make up the pose
- `double? confidence`: Overall confidence score of the pose

### Keypoint
Represents a keypoint in pose estimation.

**Properties:**
- `double x`: X coordinate of the keypoint
- `double y`: Y coordinate of the keypoint
- `double confidence`: Confidence score of the keypoint
- `String? part`: Name of the body part

### Segmentation
Represents the result of semantic segmentation.

**Properties:**
- `SegmentationMask mask`: The segmentation mask
- `String? imagePath`: Optional path to saved segmentation image
- `Map<int, Map<String, int>>? labelColors`: Color mapping for labels

### SegmentationMask
Represents segmentation mask data.

**Properties:**
- `int width`: Width of the segmentation mask
- `int height`: Height of the segmentation mask
- `Uint8List mask`: Raw mask data as bytes
- `int? numClasses`: Number of classes in the segmentation

## Enums

### ModelType
Enum for different types of TensorFlow Lite models.

**Values:**
- `classification`: Image classification model
- `objectDetection`: Object detection model
- `poseEstimation`: Pose estimation model
- `segmentation`: Semantic segmentation model
- `custom`: Custom model type

### DelegateType
Enum for different delegate types.

**Values:**
- `cpu`: CPU delegate (default)
- `gpu`: GPU delegate for acceleration
- `nnapi`: NNAPI delegate for Android
- `metal`: Metal delegate for iOS
- `coreml`: CoreML delegate for iOS

## Usage Examples

### Basic Image Classification
```dart
// Load model
await TflitePlus.loadModel(
  model: 'assets/models/mobilenet.tflite',
  labels: 'assets/models/labels.txt',
);

// Run classification
final results = await TflitePlus.runModelOnImage(
  path: imagePath,
  numResults: 5,
  threshold: 0.1,
);

// Process results
for (var result in results ?? []) {
  print('${result['label']}: ${result['confidence']}');
}
```

### Object Detection with GPU
```dart
// Load model with GPU acceleration
await TflitePlus.loadModel(
  model: 'assets/models/ssd_mobilenet.tflite',
  labels: 'assets/models/coco_labels.txt',
  useGpuDelegate: true,
);

// Run detection
final detections = await TflitePlus.detectObjectOnImage(
  path: imagePath,
  threshold: 0.3,
  numResultsPerClass: 10,
);

// Process detections
for (var detection in detections ?? []) {
  final rect = detection['rect'];
  print('Found ${detection['label']} at (${rect['x']}, ${rect['y']})');
}
```

### Pose Estimation
```dart
// Load PoseNet model
await TflitePlus.loadModel(
  model: 'assets/models/posenet.tflite',
);

// Run pose estimation
final poses = await TflitePlus.runPoseNetOnImage(
  path: imagePath,
  threshold: 0.5,
);

// Process poses
for (var pose in poses ?? []) {
  final keypoints = pose['keypoints'];
  for (var keypoint in keypoints) {
    print('${keypoint['part']}: (${keypoint['x']}, ${keypoint['y']})');
  }
}
```

## Error Handling

All methods can throw exceptions. It's recommended to wrap calls in try-catch blocks:

```dart
try {
  final result = await TflitePlus.loadModel(
    model: 'assets/models/model.tflite',
  );
  print('Model loaded: $result');
} catch (e) {
  print('Error loading model: $e');
}
```

## Performance Considerations

1. **Use GPU acceleration** when available for faster inference
2. **Resize images** to model input size before processing
3. **Use quantized models** for better performance and smaller size
4. **Process images asynchronously** to avoid blocking the UI
5. **Close models** when not needed to free memory

## Platform-Specific Notes

### Android
- Minimum SDK: API level 21 (Android 5.0)
- GPU delegate requires OpenGL ES 3.1
- NNAPI delegate available on Android 8.1+

### iOS
- Minimum version: iOS 12.0
- Metal delegate requires A8 processor or newer
- CoreML delegate available on iOS 11+