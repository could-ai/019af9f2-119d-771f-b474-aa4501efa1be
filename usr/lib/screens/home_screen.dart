import 'package:flutter/material.dart';
import '../services/mock_translation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final MockTranslationService _translationService = MockTranslationService();
  
  String _sourceLanguage = 'Auto';
  String _targetLanguage = 'Chinese';
  String _translatedText = '';
  bool _isLoading = false;

  final List<String> _languages = [
    'Auto',
    'English',
    'Chinese',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Korean',
  ];

  final List<String> _targetLanguages = [
    'English',
    'Chinese',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Korean',
  ];

  Future<void> _handleTranslate() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    try {
      // In a real app, this would call the OpenAI API via a backend function
      final result = await _translationService.translate(
        _inputController.text,
        _sourceLanguage,
        _targetLanguage,
      );

      if (mounted) {
        setState(() {
          _translatedText = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selection Row
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _sourceLanguage,
                      underline: Container(),
                      items: _languages.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _sourceLanguage = newValue!;
                        });
                      },
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    DropdownButton<String>(
                      value: _targetLanguage,
                      underline: Container(),
                      items: _targetLanguages.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _targetLanguage = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Input Area
            const Text(
              'Original Text',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter text to translate...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),

            // Translate Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleTranslate,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      ) 
                    : const Icon(Icons.translate),
                label: Text(_isLoading ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Output Area
            if (_translatedText.isNotEmpty || _isLoading) ...[
              const Text(
                'Translation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                child: _isLoading
                    ? const Center(child: Text('Thinking...'))
                    : SelectableText(
                        _translatedText,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
