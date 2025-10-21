import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class TextClassificationExample extends StatefulWidget {
  const TextClassificationExample({super.key});

  @override
  State<TextClassificationExample> createState() =>
      _TextClassificationExampleState();
}

class _TextClassificationExampleState extends State<TextClassificationExample> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic>? _results;
  bool _busy = false;

  final List<String> _sampleTexts = [
    "I love this movie! It's absolutely fantastic and entertaining.",
    "This product is terrible. I hate it and want my money back.",
    "The weather is nice today. Perfect for a walk in the park.",
    "I'm not sure about this. It could be good or bad.",
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/text_classification.tflite',
        labels: 'assets/models/text_classification_vocab.txt',
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

  Future<void> _classifyText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      var results = await TflitePlus.runModelOnImage(
        path: text, // Note: This would need a different API for text
        numResults: 3,
        threshold: 0.1,
      );
      setState(() {
        _results = results;
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Classification failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Classification'),
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
                      'Sentiment Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Analyze sentiment and classify text content.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter text to classify...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _classifyText(_textController.text),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Classify Text'),
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
                    const Text(
                      'Sample Texts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._sampleTexts.map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () {
                            _textController.text = text;
                            _classifyText(text);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_results != null) ...[
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
                            Text('Classifying text...'),
                          ],
                        )
                      else ...[
                        const Text(
                          'Classification Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._results!.map(
                          (result) => ListTile(
                            title: Text(result['label'] ?? 'Unknown'),
                            trailing: Text(
                              '${((result['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
