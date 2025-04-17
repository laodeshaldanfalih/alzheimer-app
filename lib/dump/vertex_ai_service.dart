import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

class VertexAIService {
  final FirebaseVertexAI _vertexAI;
  late GenerativeModel _generativeModel;

  VertexAIService() : _vertexAI = FirebaseVertexAI.instance {
    _initializeModel();
  }

  void _initializeModel() {
    _generativeModel = _vertexAI.generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 300,
      ),
    );
  }

  Future<String> generateText(String prompt) async {
    try {
      if (prompt.isEmpty) return 'Prompt tidak boleh kosong';
      
      final response = await _generativeModel.generateContent([
        Content.text(prompt)
      ]);

      return response.text ?? 'Tidak ada respons';
    } catch (e) {
      debugPrint('Error generating text: $e');
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  Future<List<String>> generateMultipleResponses(String prompt, int count) async {
    if (prompt.isEmpty) return ['Prompt tidak boleh kosong'];
    if (count <= 0) return ['Jumlah respons harus > 0'];

    final List<String> responses = [];
    
    try {
      for (int i = 0; i < count; i++) {
        final response = await _generativeModel.generateContent([
          Content.text(prompt)
        ]);
        responses.add(response.text ?? 'Tidak ada respons ${i+1}');
      }
    } catch (e) {
      debugPrint('Error in batch generation: $e');
      responses.add('Gagal menghasilkan respons: ${e.toString()}');
    }

    return responses;
  }
}