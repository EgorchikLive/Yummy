import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy/pages/add_page.dart';
import 'package:yummy/pages/delete_foods_page.dart';
import 'package:yummy/pages/edit_foods_page.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<List<Map<String, dynamic>>> getFoodList() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('foods').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id': data['id'] ?? '',
        'name': data['name'] ?? 'Без названия',
        'image': data['image'] ?? '',
        'price': data['price'] ?? 0,
        'discount': data['discount'] ?? 0.0,
        'description': data['description'] ?? '',
      };
    }).toList();
  }

  Future<bool> isUserAdmin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      print('Ошибка при проверке роли: $e');
      return false;
    }
  }

void _addFoodItem(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddPage()),
  ).then((result) {
    if (result == true) {
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Список товаров обновлен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  });
}

void _editFoodItems(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const EditFoodsPage()),
  );
}

void _deleteFoodItems(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DeleteFoodsPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          FutureBuilder<bool>(
            future: isUserAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data == true) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addFoodItem(context),
                      tooltip: 'Добавить товар',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editFoodItems(context),
                      tooltip: 'Редактировать товары',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFoodItems(context),
                      tooltip: 'Удалить товары',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
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
                id: foodList[index]['id'] ?? '',
                name: foodList[index]['name'] ?? 'Без названия',
                imageUrl: foodList[index]['image'] ?? '',
                price: foodList[index]['price'] ?? 0,
                discount: foodList[index]['discount'] ?? 0.0,
                description: foodList[index]['description'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:yummy/widgets/card_page.dart';

// class MainPage extends StatelessWidget {
//   const MainPage({super.key});

//   Future<List<Map<String, dynamic>>> getFoodList() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('foods').get();
//     return snapshot.docs.map((doc) {
//       var data = doc.data() as Map<String, dynamic>;
//       return {
//         'id':
//             data['id'] ?? '',
//         'name': data['name'] ??
//             'Без названия',
//         'image': data['image'] ??
//             '',
//         'price': data['price'] ?? 0,
//         'discount': data['discount'] ??
//             0.0,
//         'description': data['description'] ?? '',
//       };
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Главная')),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: getFoodList(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Нет данных'));
//           }

//           final foodList = snapshot.data!;

//           return ListView.builder(
//             itemCount: foodList.length,
//             itemBuilder: (context, index) {
//               return CardPage(
//                 id: foodList[index]['id'] ??
//                     '',
//                 name: foodList[index]['name'] ??
//                     'Без названия',
//                 imageUrl: foodList[index]['image'] ??
//                     '',
//                 price: foodList[index]['price'] ??
//                     0,
//                 discount: foodList[index]['discount'] ??
//                     0.0,
//                 description: foodList[index]['description'] ??
//                       '',
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
