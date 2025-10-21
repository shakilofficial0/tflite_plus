import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_plus/tflite_plus.dart';

class ObjectDetectionExample extends StatefulWidget {
  const ObjectDetectionExample({super.key});

  @override
  State<ObjectDetectionExample> createState() => _ObjectDetectionExampleState();
}

class _ObjectDetectionExampleState extends State<ObjectDetectionExample> {
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
        model: 'assets/models/ssd_mobilenet.tflite',
        labels: 'assets/models/ssd_mobilenet.txt',
        numThreads: 1,
        useGpuDelegate: false,
        isAsset: true,
      );
      print('Object detection model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _detectObjects(File image) async {
    setState(() {
      _busy = true;
    });

    try {
      var recognitions = await TflitePlus.detectObjectOnImage(
        path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,
        numResultsPerClass: 10,
      );

      setState(() {
        _recognitions = recognitions;
        _busy = false;
      });
    } catch (e) {
      print('Object detection error: $e');
      setState(() {
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Object detection failed: $e')),
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
      await _detectObjects(_image!);
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
      await _detectObjects(_image!);
    }
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
        title: const Text('Object Detection'),
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
                      'SSD MobileNet Object Detection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Detect objects in images with bounding boxes using SSD MobileNet.',
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image!,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (_recognitions != null && !_busy)
                            ..._recognitions!.map((recognition) {
                              final rect = recognition['rect'];
                              if (rect != null) {
                                return Positioned(
                                  left: rect['x'] * 300,
                                  top: rect['y'] * 300,
                                  width: rect['w'] * 300,
                                  height: rect['h'] * 300,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    child: Container(
                                      color: Colors.red.withOpacity(0.1),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          color: Colors.red,
                                          padding: const EdgeInsets.all(2),
                                          child: Text(
                                            '${recognition['detectedClass']} ${((recognition['confidenceInClass'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_busy)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Detecting objects...'),
                          ],
                        )
                      else if (_recognitions != null) ...[
                        const Text(
                          'Detection Results:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_recognitions!.isEmpty)
                          const Text('No objects detected')
                        else
                          ..._recognitions!.take(5).map((recognition) => Card(
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              title: Text(recognition['detectedClass'] ?? 'Unknown'),
                              trailing: Text(
                                '${((recognition['confidenceInClass'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  '${(_recognitions!.indexOf(recognition) + 1)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )),
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