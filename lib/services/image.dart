import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      // Request permission if needed
      var status = await Permission.photos.request();
      if (!status.isGranted) {
        return null;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  // Take photo with camera
  Future<File?> takePhoto() async {
    try {
      // Request camera permission
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        return null;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
    return null;
  }
}