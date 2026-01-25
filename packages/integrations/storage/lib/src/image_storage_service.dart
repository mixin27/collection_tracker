import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class ImageStorageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImage(image);
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<List<String>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      final List<String> savedPaths = [];
      for (final image in images) {
        final path = await _saveImage(image);
        if (path != null) {
          savedPaths.add(path);
        }
      }

      return savedPaths;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  Future<String?> _saveImage(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final savedPath = path.join(imagesDir.path, fileName);

      // Read and compress image
      final imageBytes = await File(image.path).readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed (max 1920x1920)
      img.Image resized = decodedImage;
      if (decodedImage.width > 1920 || decodedImage.height > 1920) {
        resized = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1920 : null,
          height: decodedImage.height > decodedImage.width ? 1920 : null,
        );
      }

      // Save compressed image
      final compressed = img.encodeJpg(resized, quality: 85);
      await File(savedPath).writeAsBytes(compressed);

      return savedPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  Future<void> deleteImages(List<String> imagePaths) async {
    for (final path in imagePaths) {
      await deleteImage(path);
    }
  }

  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
