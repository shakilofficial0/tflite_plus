import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_plus/tflite_plus.dart';

class StyleTransferExample extends StatefulWidget {
  const StyleTransferExample({super.key});

  @override
  State<StyleTransferExample> createState() => _StyleTransferExampleState();
}

class _StyleTransferExampleState extends State<StyleTransferExample> {
  File? _image;
  String? _outputPath;
  bool _busy = false;
  final ImagePicker _picker = ImagePicker();
  String _selectedStyle = 'mosaic';

  final List<Map<String, String>> _styles = [
    {
      'name': 'Mosaic',
      'model': 'style_mosaic_transfer_int8.tflite',
      'key': 'mosaic',
    },
    {
      'name': 'Pointilism',
      'model': 'style_pointilism_transfer_int8.tflite',
      'key': 'pointilism',
    },
    {
      'name': 'Candy',
      'model': 'style_candy_transfer_int8.tflite',
      'key': 'candy',
    },
    {
      'name': 'Udnie',
      'model': 'style_udnie_transfer_int8.tflite',
      'key': 'udnie',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final selectedStyleModel = _styles.firstWhere(
        (style) => style['key'] == _selectedStyle,
      )['model']!;

      await TflitePlus.loadModel(
        model: 'assets/models/$selectedStyleModel',
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
      print('Style transfer model loaded successfully: $_selectedStyle');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load model: $e')));
    }
  }

  Future<void> _runStyleTransfer(File image) async {
    setState(() {
      _busy = true;
    });

    try {
      await TflitePlus.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 1,
        threshold: 0.1,
      );

      // Note: In a real implementation, style transfer would return an image path
      // For this example, we'll simulate the output
      setState(() {
        _outputPath = image.path; // Placeholder
        _busy = false;
      });
    } catch (e) {
      print('Style transfer error: $e');
      setState(() {
        _busy = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Style transfer failed: $e')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _outputPath = null;
      });
      await _runStyleTransfer(_image!);
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
        title: const Text('Style Transfer'),
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
                      'Neural Style Transfer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Apply artistic styles to your photos using neural networks.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: _selectedStyle,
                      isExpanded: true,
                      onChanged: _busy
                          ? null
                          : (String? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  _selectedStyle = newValue;
                                });
                                await _loadModel();
                                if (_image != null) {
                                  await _runStyleTransfer(_image!);
                                }
                              }
                            },
                      items: _styles.map<DropdownMenuItem<String>>((style) {
                        return DropdownMenuItem<String>(
                          value: style['key'],
                          child: Text(style['name']!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _pickImage(ImageSource.gallery),
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Original',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _image!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Styled (${_styles.firstWhere((s) => s['key'] == _selectedStyle)['name']})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_busy)
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[300],
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 8),
                                          Text('Applying style...'),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (_outputPath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_outputPath!),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
}
