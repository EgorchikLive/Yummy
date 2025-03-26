import 'package:flutter/material.dart';
import 'package:yummy/pages/test_list.dart';
import 'package:yummy/widgets/card_page.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Скидки')),
      body: ListView.builder(
        itemCount: foodList
            .where((item) => double.parse(item['discount']!.toString()) > 0)
            .length,
        itemBuilder: (context, index) {
          final filteredList = foodList
              .where((item) => double.parse(item['discount']!.toString()) > 0)
              .toList();
          return CardPage(
            id: foodList[index]['id']!,
            name: filteredList[index]['name']!,
            imageUrl: filteredList[index]['image']!,
            price: int.parse(filteredList[index]['price']!.toString()),
            discount: double.parse(filteredList[index]['discount']!.toString()),
          );
        },
      ),
    );
  }
}
