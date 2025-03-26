import 'package:flutter/material.dart';
import 'package:yummy/pages/test_list.dart';
import 'package:yummy/widgets/card_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: ListView.builder(
        itemCount: foodList.length,
        itemBuilder: (context, index) {
          return CardPage(
            id: foodList[index]['id']!,
            name: foodList[index]['name']!,
            // description: foodList[index]['description']!,
            imageUrl: foodList[index]['image']!,
            price: int.parse(foodList[index]['price']!.toString()),
            discount: double.parse(foodList[index]['discount']!.toString()),
            // onTap: () {},
          );
        },
      ),
    );
  }
}
