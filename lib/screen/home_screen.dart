import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myocr/services/api.dart';
import 'package:myocr/services/image.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ocr_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeepSeekAPIService _apiService = DeepSeekAPIService();
  final ImageService _imageService = ImageService();
  
  File? _selectedImage;
  OcrResult? _OcrResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final image = await _imageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _OcrResult = null; // Clear previous result
      });
    }
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    final photo = await _imageService.takePhoto();
    if (photo != null) {
      setState(() {
        _selectedImage = photo;
        _OcrResult = null;
      });
    }
  }

  // Extract text from image
  Future<void> _extractText() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.extractTextFromImage(_selectedImage!);
      
      setState(() {
        _OcrResult = result;
        _isLoading = false;
      });

      if (!result.isSuccess) {
        _showSnackBar(result.error ?? 'Extraction failed', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _OcrResult = OcrResult.failure('Error: $e');
      });
      _showSnackBar('Error occurred', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Save extracted text to file
  Future<void> _saveTextToFile() async {
    if (_OcrResult == null || !_OcrResult!.isSuccess) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/extracted_text_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      await file.writeAsString(_OcrResult!.extracted_text);
      
      _showSnackBar('Text saved to: ${file.path}', Colors.green);
    } catch (e) {
      _showSnackBar('Error saving file', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepSeek OCR'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                    'This app uses DeepSeek AI model from Hugging Face '
                    'to extract text from images using OCR technology.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image selection area
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Image display
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No image selected',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image selection buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Extract button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _extractText,
              icon: _isLoading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.text_fields),
              label: Text(_isLoading ? 'Extracting...' : 'Extract Text'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results area
            if (_OcrResult != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Extracted Text',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (_OcrResult!.isSuccess)
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _saveTextToFile,
                              tooltip: 'Save to file',
                            ),
                        ],
                      ),
                      const Divider(),
                      
                      if (_OcrResult!.isSuccess)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SelectableText(
                            _OcrResult!.extracted_text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            _OcrResult!.error ?? 'Unknown error',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                            ),
                          ),
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