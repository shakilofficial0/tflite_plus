import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class BertQAExample extends StatefulWidget {
  const BertQAExample({super.key});

  @override
  State<BertQAExample> createState() => _BertQAExampleState();
}

class _BertQAExampleState extends State<BertQAExample> {
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  String? _answer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _contextController.text =
        "TensorFlow Lite is Google's lightweight solution for mobile and embedded devices. It enables on-device machine learning inference with low latency and small binary size.";
  }

  Future<void> _loadModel() async {
    try {
      await TflitePlus.loadModel(
        model: 'assets/models/mobilebert_float_20191023.tflite',
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

  Future<void> _answerQuestion() async {
    if (_contextController.text.trim().isEmpty ||
        _questionController.text.trim().isEmpty)
      return;

    setState(() => _busy = true);
    try {
      // Note: This would require a specialized BERT QA method
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      setState(() {
        _answer = "Sample answer based on the context provided.";
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Question answering failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BERT Q&A'),
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
                      'BERT Question Answering',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contextController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Context',
                        hintText: 'Provide context information...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        hintText: 'Ask a question about the context...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _answerQuestion,
                      icon: const Icon(Icons.question_answer),
                      label: const Text('Get Answer'),
                    ),
                  ],
                ),
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Processing question...'),
                    ],
                  ),
                ),
              ),
            ],
            if (_answer != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Answer:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_answer!),
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
