import 'package:flutter/material.dart';

class MedicalTest {
  final String id;
  final String name;
  final double price;

  MedicalTest({required this.id, required this.name, required this.price});
}

class TestCartProvider with ChangeNotifier {
  final List<MedicalTest> _selectedTests = [];

  List<MedicalTest> get selectedTests => List.unmodifiable(_selectedTests);

  double get totalAmount {
    return _selectedTests.fold(0, (sum, item) => sum + item.price);
  }

  void toggleTest(MedicalTest test) {
    final index = _selectedTests.indexWhere((t) => t.id == test.id);
    if (index >= 0) {
      _selectedTests.removeAt(index);
    } else {
      _selectedTests.add(test);
    }
    notifyListeners();
  }

  bool isSelected(String id) {
    return _selectedTests.any((t) => t.id == id);
  }

  void clear() {
    _selectedTests.clear();
    notifyListeners();
  }
}
