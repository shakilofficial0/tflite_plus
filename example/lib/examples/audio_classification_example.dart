import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class AudioClassificationExample extends StatefulWidget {
  const AudioClassificationExample({super.key});

  @override
  State<AudioClassificationExample> createState() =>
      _AudioClassificationExampleState();
}

class _AudioClassificationExampleState
    extends State<AudioClassificationExample> {
  List<dynamic>? _results;
  bool _busy = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/yamnet.tflite',
        labels: 'assets/models/yamnet_label_list.txt',
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

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _busy = true;
    });

    // Simulate recording and classification
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isRecording = false;
      _busy = false;
      _results = [
        {'label': 'Speech', 'confidence': 0.85},
        {'label': 'Music', 'confidence': 0.12},
        {'label': 'Silence', 'confidence': 0.03},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Classification'),
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
                      'YAMNet Audio Classification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Classify sounds and audio events using YAMNet.',
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _busy ? null : _startRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording
                          ? 'Recording... (3s)'
                          : 'Tap to start recording',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            if (_results != null) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Classification Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _results!.length,
                            itemBuilder: (context, index) {
                              final result = _results![index];
                              return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(result['label'] ?? 'Unknown'),
                                  trailing: Text(
                                    '${((result['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
