class OcrResult {
  final String extracted_text;
  final String? error;
  final bool isSuccess;
  final DateTime timestamps;

  OcrResult({
    required this.extracted_text,
    this.error,
    required this.isSuccess,
    required this.timestamps,
  });

  factory OcrResult.success(String text) {
    return OcrResult(
      extracted_text: text,
      isSuccess: true,
      timestamps: DateTime.now(),
    );
  }
  factory OcrResult.failure(String error) {
    return OcrResult(
      extracted_text: "We Have Error",
      isSuccess: false,
      timestamps: DateTime.now(),
      error: error
    );
  }
}
