import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/selected_document.dart';

class FileHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<SelectedDocument?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) {
        return null;
      }

      return SelectedDocument(
        name: pickedFile.name,
        path: pickedFile.path.isEmpty ? null : pickedFile.path,
        bytes: await pickedFile.readAsBytes(),
        mimeType: pickedFile.mimeType,
      );
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  static Future<SelectedDocument?> pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        return null;
      }

      final file = result.files.single;
      return SelectedDocument(
        name: file.name,
        path: file.path,
        bytes: file.bytes,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      debugPrint("Error picking PDF: $e");
      return null;
    }
  }
}
