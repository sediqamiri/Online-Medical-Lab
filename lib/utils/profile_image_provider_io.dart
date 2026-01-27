import 'dart:io';

import 'package:flutter/material.dart';

import 'profile_image_codec.dart';

ImageProvider<Object>? buildProfileImage(String? path) {
  final normalizedPath = path?.trim();
  if (normalizedPath == null || normalizedPath.isEmpty) {
    return null;
  }

  final embeddedBytes = decodeProfileImage(normalizedPath);
  if (embeddedBytes != null) {
    return MemoryImage(embeddedBytes);
  }

  final uri = Uri.tryParse(normalizedPath);
  if (uri != null &&
      (uri.scheme == 'http' ||
          uri.scheme == 'https')) {
    return NetworkImage(normalizedPath);
  }

  return FileImage(File(normalizedPath));
}
