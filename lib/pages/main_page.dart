import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy/widgets/card_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<List<Map<String, dynamic>>> getFoodList() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id':
            data['id'] ?? '',
        'name': data['name'] ??
            'Без названия',
        'image': data['image'] ??
            '',
        'price': data['price'] ?? 0,
        'discount': data['discount'] ??
            0.0,
        'description': data['description'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getFoodList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }

          final foodList = snapshot.data!;

          return ListView.builder(
            itemCount: foodList.length,
            itemBuilder: (context, index) {
              return CardPage(
                id: foodList[index]['id'] ??
                    '',
                name: foodList[index]['name'] ??
                    'Без названия',
                imageUrl: foodList[index]['image'] ??
                    '',
                price: foodList[index]['price'] ??
                    0,
                discount: foodList[index]['discount'] ??
                    0.0,
                description: foodList[index]['description'] ??
                      '',
              );
            },
          );
        },
      ),
    );
  }
}
