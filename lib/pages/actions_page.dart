import 'package:flutter/material.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  Future<List<Map<String, dynamic>>> getFoodListWithDiscount() async {
    // Получаем данные из Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();
    return snapshot.docs
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'id': data['id'] ?? '',
            'name': data['name'] ?? 'Без названия',
            'image': data['image'] ?? '',
            'price': data['price'] ?? 0,
            'discount': data['discount'] ?? 0.0,
          };
        })
        .where((item) => item['discount'] > 0) // Отбираем товары со скидкой
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Скидки')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getFoodListWithDiscount(), // Загружаем товары с акциями
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет товаров с акциями'));
          }

          final discountFoodList = snapshot.data!;

          return ListView.builder(
            itemCount: discountFoodList.length,
            itemBuilder: (context, index) {
              return CardPage(
                id: discountFoodList[index]['id']!,
                name: discountFoodList[index]['name']!,
                imageUrl: discountFoodList[index]['image']!,
                price: discountFoodList[index]['price']!,
                discount: discountFoodList[index]['discount']!,
              );
            },
          );
        },
      ),
    );
  }
}
