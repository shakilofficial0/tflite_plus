import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class LiveDetectionExample extends StatefulWidget {
  const LiveDetectionExample({super.key});

  @override
  State<LiveDetectionExample> createState() => _LiveDetectionExampleState();
}

class _LiveDetectionExampleState extends State<LiveDetectionExample> {
  bool _isDetecting = false;
  List<dynamic>? _recognitions;
  bool _isModelLoaded = false;
  Timer? _simulationTimer;

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
      setState(() {
        _isModelLoaded = true;
      });
      print('Live detection model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  void _startDetection() {
    if (!_isModelLoaded) return;
    
    setState(() {
      _isDetecting = true;
    });

    // Simulate live detection with periodic updates
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isDetecting) {
        timer.cancel();
        return;
      }
      _simulateDetection();
    });
  }

  void _stopDetection() {
    setState(() {
      _isDetecting = false;
    });
    _simulationTimer?.cancel();
  }

  void _simulateDetection() {
    final random = math.Random();
    
    // Simulate detected objects
    final objects = ['person', 'car', 'bicycle', 'dog', 'cat', 'bottle', 'chair'];
    final numObjects = random.nextInt(3) + 1;
    
    List<dynamic> detections = [];
    for (int i = 0; i < numObjects; i++) {
      detections.add({
        'detectedClass': objects[random.nextInt(objects.length)],
        'confidenceInClass': 0.6 + random.nextDouble() * 0.4,
        'rect': {
          'x': random.nextDouble() * 0.6,
          'y': random.nextDouble() * 0.6,
          'w': 0.1 + random.nextDouble() * 0.2,
          'h': 0.1 + random.nextDouble() * 0.2,
        },
      });
    }

    setState(() {
      _recognitions = detections;
    });
  }

  Widget _buildBoundingBoxes() {
    if (_recognitions == null || _recognitions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: _recognitions!.map<Widget>((recognition) {
        final rect = recognition['rect'];
        if (rect != null) {
          return Positioned(
            left: rect['x'] * 300,
            top: rect['y'] * 400,
            width: rect['w'] * 300,
            height: rect['h'] * 400,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  color: Colors.green,
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
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    TflitePlus.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Detection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
            onPressed: _isDetecting ? _stopDetection : _startDetection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Simulated Live Detection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This simulates real-time object detection. In a real implementation, this would use camera input.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isModelLoaded ? Icons.check_circle : Icons.hourglass_empty,
                          color: _isModelLoaded ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(_isModelLoaded ? 'Model Ready' : 'Loading Model...'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detection View',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isDetecting ? Colors.red : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _isDetecting ? 'LIVE' : 'STOPPED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: _isDetecting
                                  ? const Text(
                                      'Simulated Camera Feed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.videocam_off,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Detection Stopped',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                              if (_isDetecting) _buildBoundingBoxes(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detection Results:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_recognitions != null && _recognitions!.isNotEmpty) ...[
                              ...(_recognitions!.take(3).map((recognition) => Text(
                                '• ${recognition['detectedClass']} (${((recognition['confidenceInClass'] ?? 0.0) * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ))),
                            ] else
                              const Text(
                                'No objects detected',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}