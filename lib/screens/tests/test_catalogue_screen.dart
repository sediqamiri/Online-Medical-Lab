import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/test_cart_provider.dart';

class TestCatalogueScreen extends StatelessWidget {
  const TestCatalogueScreen({super.key});

  final List<Map<String, dynamic>> availableTests = const [
    {'id': '1', 'name': 'Full Blood Count', 'price': 45.0},
    {'id': '2', 'name': 'Lipid Profile', 'price': 60.0},
    {'id': '3', 'name': 'Thyroid (T3, T4, TSH)', 'price': 85.0},
    {'id': '4', 'name': 'Glucose Fasting', 'price': 25.0},
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<TestCartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Tests"),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _showCheckoutSheet(context),
              ),
              if (cart.selectedTests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.selectedTests.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableTests.length,
        itemBuilder: (context, index) {
          final testData = availableTests[index];
          final test = MedicalTest(
            id: testData['id'],
            name: testData['name'],
            price: testData['price'],
          );
          final bool isAdded = cart.isSelected(test.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(test.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("\$${test.price.toStringAsFixed(2)}"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAdded ? Colors.grey : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => cart.toggleTest(test),
                child: Text(isAdded ? "Remove" : "Add"),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.selectedTests.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/appointment'),
                child: Text(
                    "Book ${cart.selectedTests.length} Tests (\$${cart.totalAmount})"),
              ),
            ),
    );
  }

  void _showCheckoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final cart = context.watch<TestCartProvider>();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Your Selection",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              ...cart.selectedTests.map((t) => ListTile(
                    title: Text(t.name),
                    trailing: Text("\$${t.price}"),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("\$${cart.totalAmount}",
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/appointment');
                  },
                  child: const Text("PROCEED TO BOOKING"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
