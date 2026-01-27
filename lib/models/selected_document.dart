import 'dart:typed_data';

class SelectedDocument {
  const SelectedDocument({
    required this.name,
    this.path,
    this.bytes,
    this.mimeType,
  });

  final String name;
  final String? path;
  final Uint8List? bytes;
  final String? mimeType;

  bool get isPdf {
    final lowerName = name.toLowerCase();
    return lowerName.endsWith('.pdf') || mimeType == 'application/pdf';
  }

  bool get hasImagePreview => !isPdf && bytes != null && bytes!.isNotEmpty;
}
