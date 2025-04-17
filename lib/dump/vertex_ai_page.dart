import 'package:flutter/material.dart';
import 'package:project/dump/vertex_ai_service.dart';

class VertexAIPage extends StatefulWidget {
  const VertexAIPage({super.key});

  @override
  State<VertexAIPage> createState() => _VertexAIPageState();
}

class _VertexAIPageState extends State<VertexAIPage> {
  final VertexAIService _vertexAIService = VertexAIService();
  final TextEditingController _promptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<String> _generatedResponses = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _generateResponses() async {
    if (!_formKey.currentState!.validate()) return;
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedResponses.clear();
      _errorMessage = null;
    });

    try {
      final responses = await _vertexAIService.generateMultipleResponses(
        _promptController.text, 
        3
      );

      setState(() {
        _generatedResponses = responses;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vertex AI Generator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Prompt',
                  border: OutlineInputBorder(),
                  hintText: 'Ketik prompt untuk AI...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prompt tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateResponses,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Generate Respons'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _generatedResponses.isEmpty
                      ? const Center(
                          child: Text(
                            'Hasil akan muncul di sini',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _generatedResponses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Respons ${index + 1}:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_generatedResponses[index]),
                                  ],
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
    );
  }
}