import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy/widgets/card_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<List<Map<String, dynamic>>> getFoodList() async {
    // Получаем данные из Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      // Добавляем проверки на null для полей
      return {
        'id':
            data['id'] ?? '', // Если 'id' равно null, используем пустую строку
        'name': data['name'] ??
            'Без названия', // Если 'name' равно null, используем 'Без названия'
        'image': data['image'] ??
            '', // Если 'image' равно null, используем пустую строку
        'price': data['price'] ?? 0, // Если 'price' равно null, используем 0
        'discount': data['discount'] ??
            0.0, // Если 'discount' равно null, используем 0.0
        'description': data['description'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getFoodList(), // Загружаем список продуктов
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

          // Полученные данные
          final foodList = snapshot.data!;

          return ListView.builder(
            itemCount: foodList.length,
            itemBuilder: (context, index) {
              return CardPage(
                id: foodList[index]['id'] ??
                    '', // Если id равно null, используем пустую строку
                name: foodList[index]['name'] ??
                    'Без названия', // Если name равно null, используем 'Без названия'
                imageUrl: foodList[index]['image'] ??
                    '', // Если image равно null, используем пустую строку
                price: foodList[index]['price'] ??
                    0, // Если price равно null, используем 0
                discount: foodList[index]['discount'] ??
                    0.0, // Если discount равно null, используем 0.0
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
