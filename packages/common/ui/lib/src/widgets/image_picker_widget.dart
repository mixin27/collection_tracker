import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback? onRemove;
  final double size;

  const ImagePickerWidget({
    this.imagePath,
    this.imageUrl,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    this.onRemove,
    this.size = 120,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 2),
            ),
            child: _buildImage(theme),
          ),
        ),
        const SizedBox(height: 8),
        if ((imagePath != null || imageUrl != null) && onRemove != null)
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Remove'),
          )
        else
          TextButton.icon(
            onPressed: () => _showImageSourceDialog(context),
            icon: const Icon(Icons.add_a_photo, size: 18),
            label: const Text('Add Photo'),
          ),
      ],
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(imagePath!), fit: BoxFit.cover),
      );
    } else if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (context, url, error) => Icon(
            Icons.image_not_supported,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.add_photo_alternate,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            if (imagePath != null && onRemove != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemove!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
