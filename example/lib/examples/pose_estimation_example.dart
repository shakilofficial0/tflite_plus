import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_plus/tflite_plus.dart';

class PoseEstimationExample extends StatefulWidget {
  const PoseEstimationExample({super.key});

  @override
  State<PoseEstimationExample> createState() => _PoseEstimationExampleState();
}

class _PoseEstimationExampleState extends State<PoseEstimationExample> {
  File? _image;
  List<dynamic>? _recognitions;
  bool _busy = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/posenet_mv1_075_float_from_checkpoints.tflite',
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
      print('Pose estimation model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _runPoseEstimation(File image) async {
    setState(() {
      _busy = true;
    });

    try {
      var recognitions = await TflitePlus.runPoseNetOnImage(
        path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 5,
        threshold: 0.1,
      );

      setState(() {
        _recognitions = recognitions;
        _busy = false;
      });
    } catch (e) {
      print('Pose estimation error: $e');
      setState(() {
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pose estimation failed: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _runPoseEstimation(_image!);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _runPoseEstimation(_image!);
    }
  }

  Widget _buildPoseKeypoints() {
    if (_recognitions == null || _recognitions!.isEmpty || _image == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Image.file(
          _image!,
          height: 400,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
        ..._recognitions!.expand((pose) {
          final keypoints = pose['keypoints'] as List<dynamic>? ?? [];
          return keypoints.map<Widget>((keypoint) {
            final x = keypoint['x'] ?? 0.0;
            final y = keypoint['y'] ?? 0.0;
            final confidence = keypoint['confidence'] ?? 0.0;
            
            if (confidence > 0.3) {
              return Positioned(
                left: x * 400 - 3,
                top: y * 400 - 3,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    TflitePlus.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Estimation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'PoseNet Human Pose Estimation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Detect human poses and keypoints using PoseNet model.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_image != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_busy)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Analyzing pose...'),
                          ],
                        )
                      else ...[
                        _buildPoseKeypoints(),
                        const SizedBox(height: 16),
                        if (_recognitions != null) ...[
                          const Text(
                            'Pose Analysis Results:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (_recognitions!.isEmpty)
                            const Text('No poses detected')
                          else
                            ..._recognitions!.map((pose) {
                              final score = pose['score'] ?? 0.0;
                              final keypoints = pose['keypoints'] as List<dynamic>? ?? [];
                              final visibleKeypoints = keypoints
                                  .where((kp) => (kp['confidence'] ?? 0.0) > 0.3)
                                  .length;
                              
                              return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                  title: Text('Pose ${_recognitions!.indexOf(pose) + 1}'),
                                  subtitle: Text('$visibleKeypoints visible keypoints'),
                                  trailing: Text(
                                    '${(score * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: const Icon(
                                      Icons.accessibility,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                          const Text(
                            'Red dots indicate detected keypoints (confidence > 30%)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
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
}