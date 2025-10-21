import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_plus/tflite_plus.dart';

// Import all example screens
import 'examples/image_classification_example.dart';
import 'examples/object_detection_example.dart';
import 'examples/pose_estimation_example.dart';
import 'examples/image_segmentation_example.dart';
import 'examples/style_transfer_example.dart';
import 'examples/super_resolution_example.dart';
import 'examples/text_classification_example.dart';
import 'examples/bert_qa_example.dart';
import 'examples/audio_classification_example.dart';
import 'examples/gesture_classification_example.dart';
import 'examples/digit_classification_example.dart';
import 'examples/live_detection_example.dart';
import 'examples/model_manager_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TensorFlow Lite Plus Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TensorFlow Lite Plus Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategorySection(
            context,
            'Image Processing',
            [
              _ExampleItem(
                'Image Classification',
                'Classify images using MobileNet',
                Icons.image,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ImageClassificationExample(),
                )),
              ),
              _ExampleItem(
                'Object Detection',
                'Detect objects with bounding boxes',
                Icons.crop_free,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ObjectDetectionExample(),
                )),
              ),
              _ExampleItem(
                'Live Object Detection',
                'Real-time object detection with camera',
                Icons.video_camera_front,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const LiveDetectionExample(),
                )),
              ),
              _ExampleItem(
                'Pose Estimation',
                'Detect human poses and keypoints',
                Icons.accessibility,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const PoseEstimationExample(),
                )),
              ),
              _ExampleItem(
                'Image Segmentation',
                'Pixel-level image segmentation',
                Icons.layers,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ImageSegmentationExample(),
                )),
              ),
              _ExampleItem(
                'Style Transfer',
                'Apply artistic styles to images',
                Icons.palette,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const StyleTransferExample(),
                )),
              ),
              _ExampleItem(
                'Super Resolution',
                'Enhance image resolution with ESRGAN',
                Icons.high_quality,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SuperResolutionExample(),
                )),
              ),
            ],
          ),
          _buildCategorySection(
            context,
            'Text & Language',
            [
              _ExampleItem(
                'Text Classification',
                'Sentiment analysis and text classification',
                Icons.text_fields,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const TextClassificationExample(),
                )),
              ),
              _ExampleItem(
                'BERT Question Answering',
                'Answer questions using BERT model',
                Icons.question_answer,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const BertQAExample(),
                )),
              ),
            ],
          ),
          _buildCategorySection(
            context,
            'Audio & Gestures',
            [
              _ExampleItem(
                'Audio Classification',
                'Classify sounds using YAMNet',
                Icons.audiotrack,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const AudioClassificationExample(),
                )),
              ),
              _ExampleItem(
                'Gesture Classification',
                'Recognize hand gestures',
                Icons.back_hand,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const GestureClassificationExample(),
                )),
              ),
            ],
          ),
          _buildCategorySection(
            context,
            'Specialized Tasks',
            [
              _ExampleItem(
                'Digit Classification',
                'MNIST handwritten digit recognition',
                Icons.looks_one,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const DigitClassificationExample(),
                )),
              ),
              _ExampleItem(
                'Model Manager',
                'Advanced model management system',
                Icons.settings,
                () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ModelManagerExample(),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<_ExampleItem> examples,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...examples.map((example) => Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Icon(example.icon, color: Theme.of(context).primaryColor),
            title: Text(example.title),
            subtitle: Text(example.description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: example.onTap,
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ExampleItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleItem(this.title, this.description, this.icon, this.onTap);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  String _modelStatus = 'No model loaded';
  List<String> _availableDelegates = [];
  File? _selectedImage;
  List<dynamic>? _results;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    List<String> delegates;
    
    try {
      platformVersion = await TflitePlus.getPlatformVersion() ?? 'Unknown platform version';
      delegates = await TflitePlus.getAvailableDelegates() ?? [];
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      delegates = [];
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _availableDelegates = delegates;
    });
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Example: Load MobileNet model for image classification
      // You would need to add your model file to assets/models/
      final result = await TflitePlus.loadModel(
        model: 'assets/models/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/models/mobilenet_v1_1.0_224_labels.txt',
        numThreads: 1,
        useGpuDelegate: _availableDelegates.contains('GPU') || _availableDelegates.contains('Metal'),
      );

      setState(() {
        _modelStatus = result ?? 'Model loaded successfully';
      });
    } catch (e) {
      setState(() {
        _modelStatus = 'Error loading model: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _results = null;
      });
    }
  }

  Future<void> _runImageClassification() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await TflitePlus.runModelOnImage(
        path: _selectedImage!.path,
        numResults: 5,
        threshold: 0.1,
        imageMean: 117.0,
        imageStd: 1.0,
      );

      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running classification: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runObjectDetection() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await TflitePlus.detectObjectOnImage(
        path: _selectedImage!.path,
        numResultsPerClass: 5,
        threshold: 0.3,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running object detection: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runPoseEstimation() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await TflitePlus.runPoseNetOnImage(
        path: _selectedImage!.path,
        numResults: 5,
        threshold: 0.1,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running pose estimation: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _closeModel() async {
    try {
      await TflitePlus.close();
      setState(() {
        _modelStatus = 'Model closed';
        _results = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error closing model: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Platform: $_platformVersion'),
                    Text('Available Delegates: ${_availableDelegates.join(', ')}'),
                    Text('Model Status: $_modelStatus'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Operations',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _loadModel,
                          child: const Text('Load Model'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _closeModel,
                          child: const Text('Close Model'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Selection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inference Operations',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _runImageClassification,
                          child: const Text('Image Classification'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _runObjectDetection,
                          child: const Text('Object Detection'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _runPoseEstimation,
                          child: const Text('Pose Estimation'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
            if (_results != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _results.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    TflitePlus.close();
    super.dispose();
  }
}
