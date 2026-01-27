import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Report"),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("CLINICAL LAB REPORT",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary)),
                    const Icon(Icons.medical_services, color: Colors.blue),
                  ],
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 20),
                _reportRow("Patient Name:", "John Doe"),
                _reportRow("Report Date:", "Oct 24, 2023"),
                _reportRow("Laboratory:", "Alpha Medical Center"),
                const SizedBox(height: 40),
                const Text("Test Results",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                _testResult(
                    "Glucose (Fasting)", "95 mg/dL", "70-100", "Normal"),
                _testResult("Cholesterol", "210 mg/dL", "< 200", "High"),
                _testResult("Hemoglobin", "14.5 g/dL", "13.5-17.5", "Normal"),
                const Spacer(),
                const Center(
                  child: Text("Digitally Verified Report",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _testResult(String test, String result, String range, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(test, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Ref: $range",
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(result,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == "High" ? Colors.red : Colors.green)),
              Text(status,
                  style: TextStyle(
                      fontSize: 11,
                      color: status == "High" ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
