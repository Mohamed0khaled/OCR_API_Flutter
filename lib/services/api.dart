import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ocr_result.dart';

class DeepSeekAPIService {
  // OCR.space API - Free tier: 25,000 requests/month
  // Get your free API key at: https://ocr.space/ocrapi/freekey
  static const String _apiKey = 'K85674388288957'; // Free demo key (limited)
  static const String _apiUrl = 'https://api.ocr.space/parse/image';
  
  final http.Client _client = http.Client();

  // Convert image to base64 with data URI prefix
  String _encodeImage(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    
    // Detect image type from extension
    String extension = image.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }
    
    return 'data:$mimeType;base64,$base64Image';
  }

  // Send image to OCR.space API for text extraction
  Future<OcrResult> extractTextFromImage(File image) async {
    try {
      // Encode image with data URI
      String base64Image = _encodeImage(image);
      
      // Make API request using multipart form data
      final response = await _client.post(
        Uri.parse(_apiUrl),
        headers: {
          'apikey': _apiKey,
        },
        body: {
          'base64Image': base64Image,
          'language': 'eng',           // Language: eng, ara, etc.
          'isOverlayRequired': 'false',
          'detectOrientation': 'true',
          'scale': 'true',
          'OCREngine': '2',            // Engine 2 is better for most cases
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if OCR was successful
        if (responseData['IsErroredOnProcessing'] == true) {
          String errorMessage = responseData['ErrorMessage']?[0] ?? 'OCR processing failed';
          return OcrResult.failure(errorMessage);
        }
        
        // Extract parsed text from all results
        List<dynamic> parsedResults = responseData['ParsedResults'] ?? [];
        if (parsedResults.isEmpty) {
          return OcrResult.failure('No text found in image');
        }
        
        // Combine text from all parsed results
        String extractedText = parsedResults
            .map((result) => result['ParsedText'] ?? '')
            .join('\n')
            .trim();
        
        if (extractedText.isNotEmpty) {
          return OcrResult.success(extractedText);
        } else {
          return OcrResult.failure('No text found in image');
        }
      } else {
        return OcrResult.failure('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return OcrResult.failure('Network Error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}