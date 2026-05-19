import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    debugPrint('[Scan] image selected: opening camera');
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (photo == null) {
      debugPrint('[Scan] image selection cancelled (camera)');
      return null;
    }
    debugPrint('[Scan] image loaded successfully: ${photo.path}');
    return File(photo.path);
  }

  Future<File?> pickFromGallery() async {
    debugPrint('[Scan] image selected: opening gallery');
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) {
      debugPrint('[Scan] image selection cancelled (gallery)');
      return null;
    }
    debugPrint('[Scan] image loaded successfully: ${image.path}');
    return File(image.path);
  }
}
