import 'models/lab_test.dart';

final dummyTests = [
  const LabTest(
      id: 't1',
      name: 'Haemoglobin',
      category: 'Blood',
      price: 250,
      unit: 'g/dL',
      normalMin: 12.0,
      normalMax: 16.0),
  const LabTest(
      id: 't2',
      name: 'Fasting Glucose',
      category: 'Blood',
      price: 300,
      unit: 'mg/dL',
      normalMin: 70,
      normalMax: 100),
  const LabTest(
      id: 't3',
      name: 'Urine Routine',
      category: 'Urine',
      price: 150,
      unit: '—',
      normalMin: 0,
      normalMax: 0),
  const LabTest(
      id: 't4',
      name: 'Vitamin D',
      category: 'Hormone',
      price: 1200,
      unit: 'ng/mL',
      normalMin: 20,
      normalMax: 50),
];
