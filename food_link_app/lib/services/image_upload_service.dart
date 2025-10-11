import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();
  
  // Show image source selection dialog
  static Future<File?> pickImage(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    Navigator.pop(context, File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    Navigator.pop(context, File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Upload image to server (mock implementation - replace with your backend)
  static Future<String?> uploadImage(File imageFile, String type) async {
    try {
      // Convert image to base64 for mock upload
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Mock API call - replace with your actual image upload endpoint
      final response = await http.post(
        Uri.parse('http://192.168.4.88:3000/api/upload-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'type': type, // 'profile' or 'food'
          'filename': '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      } else {
        // For demo purposes, return a mock URL
        return 'https://via.placeholder.com/400x400.png?text=${type.toUpperCase()}+IMAGE';
      }
    } catch (e) {
      print('Image upload error: $e');
      // Return mock URL for demo
      return 'https://via.placeholder.com/400x400.png?text=${type.toUpperCase()}+IMAGE';
    }
  }

  // Upload multiple images (for food donations)
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles, String type) async {
    List<String> imageUrls = [];
    
    for (File file in imageFiles) {
      final url = await uploadImage(file, type);
      if (url != null) {
        imageUrls.add(url);
      }
    }
    
    return imageUrls;
  }

  // Pick multiple images
  static Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Show image picker with multiple options
  static Future<List<File>?> showImagePickerDialog(BuildContext context, {bool multiple = false}) async {
    return await showDialog<List<File>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.image, color: Colors.green),
              const SizedBox(width: 12),
              Text(multiple ? 'Select Images' : 'Select Image'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (multiple) ...[
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Multiple from Gallery'),
                  subtitle: const Text('Select multiple images'),
                  onTap: () async {
                    Navigator.pop(context);
                    final images = await pickMultipleImages();
                    Navigator.pop(context, images);
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    Navigator.pop(context, [File(image.path)]);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.orange),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    Navigator.pop(context, [File(image.path)]);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Compress image if needed
  static Future<File> compressImage(File file) async {
    // For now, return the original file
    // You can implement image compression here if needed
    return file;
  }
}
