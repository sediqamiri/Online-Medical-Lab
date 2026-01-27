import 'dart:convert';
import 'dart:typed_data';

import '../models/selected_document.dart';

String? encodeProfileImage(SelectedDocument document) {
  if (document.bytes == null || document.bytes!.isEmpty) {
    final normalizedPath = document.path?.trim();
    return normalizedPath == null || normalizedPath.isEmpty
        ? null
        : normalizedPath;
  }

  final mimeType = _resolveMimeType(document);
  final payload = base64Encode(document.bytes!);
  return 'data:$mimeType;base64,$payload';
}

Uint8List? decodeProfileImage(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty || !normalized.startsWith('data:')) {
    return null;
  }

  final commaIndex = normalized.indexOf(',');
  if (commaIndex == -1) {
    return null;
  }

  final metadata = normalized.substring(0, commaIndex).toLowerCase();
  if (!metadata.contains(';base64')) {
    return null;
  }

  try {
    return base64Decode(normalized.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}

String _resolveMimeType(SelectedDocument document) {
  final normalizedMimeType = document.mimeType?.trim().toLowerCase();
  if (normalizedMimeType != null && normalizedMimeType.startsWith('image/')) {
    return normalizedMimeType;
  }

  final candidates = [document.name, document.path ?? ''];
  for (final candidate in candidates) {
    final lowerCandidate = candidate.toLowerCase();
    if (lowerCandidate.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerCandidate.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lowerCandidate.endsWith('.gif')) {
      return 'image/gif';
    }
  }

  return 'image/jpeg';
}
