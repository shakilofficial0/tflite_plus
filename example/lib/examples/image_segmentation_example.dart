import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_plus/tflite_plus.dart';

class ImageSegmentationExample extends StatefulWidget {
  const ImageSegmentationExample({super.key});

  @override
  State<ImageSegmentationExample> createState() => _ImageSegmentationExampleState();
}

class _ImageSegmentationExampleState extends State<ImageSegmentationExample> {
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
        model: 'assets/models/deeplabv3_257_mv_gpu.tflite',
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
      print('Image segmentation model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _runSegmentation(File image) async {
    setState(() {
      _busy = true;
    });

    try {
      var recognitions = await TflitePlus.runSegmentationOnImage(
        path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _recognitions = recognitions;
        _busy = false;
      });
    } catch (e) {
      print('Segmentation error: $e');
      setState(() {
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Segmentation failed: $e')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _runSegmentation(_image!);
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
        title: const Text('Image Segmentation'),
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
                      'DeepLab v3 Image Segmentation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Perform pixel-level semantic segmentation on images.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _busy ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : () => _pickImage(ImageSource.gallery),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _image!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_busy)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Processing segmentation...'),
                          ],
                        )
                      else if (_recognitions != null) ...[
                        const Text(
                          'Segmentation Complete',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Segmented ${_recognitions!.length} pixels',
                          style: const TextStyle(fontSize: 14),
                        ),
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