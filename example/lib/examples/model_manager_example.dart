import 'package:flutter/material.dart';
import 'package:tflite_plus/tflite_plus.dart';

class ModelManagerExample extends StatefulWidget {
  const ModelManagerExample({super.key});

  @override
  State<ModelManagerExample> createState() => _ModelManagerExampleState();
}

class _ModelManagerExampleState extends State<ModelManagerExample> {
  TfLiteModelManager? _modelManager;
  List<String> _loadedModels = [];
  String? _selectedModel;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initializeManager();
  }

  Future<void> _initializeManager() async {
    setState(() => _busy = true);
    try {
      _modelManager = TfLiteModelManager();
      await _loadPredefinedModels();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to initialize: $e')));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loadPredefinedModels() async {
    if (_modelManager == null) return;

    try {
      // Simulate loading predefined models
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _loadedModels = ['mobilenet_v1', 'ssd_mobilenet', 'posenet_mv1'];
      });
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  Future<void> _unloadModel(String modelId) async {
    if (_modelManager == null) return;

    try {
      setState(() {
        _loadedModels.remove(modelId);
        if (_selectedModel == modelId) {
          _selectedModel = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unload model: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _busy
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Model Manager...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Advanced Model Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Manage multiple TensorFlow Lite models simultaneously with advanced configuration options.',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.memory, size: 16),
                              const SizedBox(width: 8),
                              Text('Loaded Models: ${_loadedModels.length}'),
                              const Spacer(),
                              const Icon(Icons.storage, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Memory Usage: ${(_loadedModels.length * 25).toStringAsFixed(0)}MB',
                              ),
                            ],
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
                            'Loaded Models',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_loadedModels.isEmpty)
                            const Text('No models loaded')
                          else
                            ..._loadedModels.map((modelId) {
                              return Card(
                                color: _selectedModel == modelId
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                    : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      modelId[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(modelId),
                                  subtitle: Text(_getModelTypeFromId(modelId)),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'select') {
                                        setState(() {
                                          _selectedModel = modelId;
                                        });
                                      } else if (value == 'unload') {
                                        _unloadModel(modelId);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'select',
                                        child: Text('Select'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'unload',
                                        child: Text('Unload'),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedModel = modelId;
                                    });
                                  },
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedModel != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Model Details: $_selectedModel',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildModelDetails(),
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
                            'Model Manager Features',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...[
                            'Multiple model support',
                            'Dynamic model loading/unloading',
                            'Memory optimization',
                            'Configuration management',
                            'Performance monitoring',
                          ].map(
                            (feature) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(feature),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getModelTypeFromId(String modelId) {
    switch (modelId) {
      case 'mobilenet_v1':
        return 'Image Classification';
      case 'ssd_mobilenet':
        return 'Object Detection';
      case 'posenet_mv1':
        return 'Pose Estimation';
      default:
        return 'Unknown Type';
    }
  }

  Widget _buildModelDetails() {
    if (_modelManager == null || _selectedModel == null) {
      return const Text('No model selected');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Model Type', _getModelTypeFromId(_selectedModel!)),
        _buildDetailRow('Model Path', 'assets/models/$_selectedModel.tflite'),
        _buildDetailRow('Labels Path', 'assets/models/$_selectedModel.txt'),
        _buildDetailRow('Input Shape', '[1, 224, 224, 3]'),
        _buildDetailRow('Output Shape', '[1, 1001]'),
        _buildDetailRow('Use GPU', 'No'),
        _buildDetailRow('Threads', '1'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
