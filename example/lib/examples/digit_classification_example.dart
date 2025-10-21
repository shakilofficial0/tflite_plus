import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class DigitClassificationExample extends StatefulWidget {
  const DigitClassificationExample({super.key});

  @override
  State<DigitClassificationExample> createState() =>
      _DigitClassificationExampleState();
}

class _DigitClassificationExampleState
    extends State<DigitClassificationExample> {
  List<List<double>> _drawingPoints = [];
  List<Offset?> _currentPath = [];
  String? _prediction;
  double? _confidence;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/mnist.tflite',
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load model: $e')));
    }
  }

  Future<void> _classifyDrawing() async {
    if (_drawingPoints.isEmpty) return;

    setState(() => _busy = true);

    try {
      // Simulate MNIST classification
      await Future.delayed(const Duration(milliseconds: 500));

      final random = math.Random();
      final digit = random.nextInt(10);
      final confidence = 0.85 + random.nextDouble() * 0.14;

      setState(() {
        _prediction = digit.toString();
        _confidence = confidence;
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Classification failed: $e')));
    }
  }

  void _clearDrawing() {
    setState(() {
      _drawingPoints.clear();
      _currentPath.clear();
      _prediction = null;
      _confidence = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Classification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearDrawing),
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
                      'MNIST Digit Recognition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Draw a digit (0-9) in the area below and get a prediction.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Draw Here',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _currentPath = [details.localPosition];
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _currentPath.add(details.localPosition);
                                });
                              },
                              onPanEnd: (details) {
                                _drawingPoints.add(
                                  _currentPath
                                      .map(
                                        (p) => p != null
                                            ? [p.dx, p.dy]
                                            : [0.0, 0.0],
                                      )
                                      .expand((x) => x)
                                      .toList(),
                                );
                                _currentPath = [];
                                _classifyDrawing();
                              },
                              child: CustomPaint(
                                painter: _DrawingPainter(_currentPath),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearDrawing,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _classifyDrawing,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Classify'),
                    ),
                  ),
                ],
              ),
            ),
            if (_prediction != null) ...[
              const SizedBox(height: 16),
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
                            Text('Classifying...'),
                          ],
                        )
                      else ...[
                        const Text(
                          'Prediction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              _prediction!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 16),
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

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
