import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class GestureClassificationExample extends StatefulWidget {
  const GestureClassificationExample({super.key});

  @override
  State<GestureClassificationExample> createState() => _GestureClassificationExampleState();
}

class _GestureClassificationExampleState extends State<GestureClassificationExample> {
  String? _currentGesture;
  double? _confidence;
  bool _isDetecting = false;

  final List<String> _gestures = [
    'Open Palm', 'Closed Fist', 'Thumbs Up', 'Peace Sign', 'Pointing'
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/gesture_classifier.tflite',
        labels: 'assets/models/gesture_labels.txt',
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _startDetection() async {
    setState(() => _isDetecting = true);
    
    // Simulate gesture detection
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _currentGesture = _gestures[DateTime.now().millisecond % _gestures.length];
      _confidence = 0.7 + (DateTime.now().millisecond % 30) / 100;
      _isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Classification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      'Hand Gesture Recognition',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Detect and classify hand gestures in real-time.'),
                    const SizedBox(height: 32),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[400]!, width: 2),
                      ),
                      child: _isDetecting
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Detecting gesture...'),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.back_hand,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Place hand in frame',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isDetecting ? null : _startDetection,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Detection'),
                    ),
                  ],
                ),
              ),
            ),
            if (_currentGesture != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Detected Gesture',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentGesture!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supported Gestures',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._gestures.map((gesture) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(gesture),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}