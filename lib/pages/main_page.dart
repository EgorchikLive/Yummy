import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy/widgets/admin_actions.dart';
import 'package:yummy/widgets/food_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isAdmin = false);
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() => _isAdmin = data['role'] == 'admin');
      } else {
        setState(() => _isAdmin = false);
      }
    } catch (e) {
      debugPrint('Ошибка проверки роли: $e');
      setState(() => _isAdmin = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          if (_isAdmin)
            AdminActions(
              onRefreshRequested: () => setState(() {}),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FoodList(isAdmin: _isAdmin),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:yummy/pages/add_page.dart';
// import 'package:yummy/pages/delete_foods_page.dart';
// import 'package:yummy/pages/edit_foods_page.dart';
// import 'package:yummy/widgets/card_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();
      
//   List<Map<String, dynamic>> _foodList = [];
//   bool _isLoading = true;
//   bool _isAdmin = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await Future.wait([
//       _loadFoodList(),
//       _checkAdminStatus(),
//     ]);
//   }

//   Future<void> _loadFoodList() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('foods').get();
//       List<Map<String, dynamic>> foodList = snapshot.docs.map((doc) {
//         var data = doc.data() as Map<String, dynamic>;
//         return {
//           'id': data['id'] ?? '',
//           'name': data['name'] ?? 'Без названия',
//           'image': data['image'] ?? '',
//           'price': data['price'] ?? 0,
//           'discount': data['discount'] ?? 0.0,
//           'description': data['description'] ?? '',
//         };
//       }).toList();

//       setState(() {
//         _foodList = foodList;
//       });
//     } catch (e) {
//       print('Ошибка загрузки данных: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _checkAdminStatus() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() {
//           _isAdmin = false;
//         });
//         return;
//       }

//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       if (userDoc.exists) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           _isAdmin = userData['role'] == 'admin';
//         });
//       } else {
//         setState(() {
//           _isAdmin = false;
//         });
//       }
//     } catch (e) {
//       print('Ошибка при проверке роли: $e');
//       setState(() {
//         _isAdmin = false;
//       });
//     }
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     await _loadData();
//   }

//   void _addFoodItem(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddPage()),
//     ).then((result) {
//       if (result == true) {
//         _refreshData();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Список товаров обновлен'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     });
//   }

//   void _editFoodItems(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const EditFoodsPage()),
//     ).then((_) {
//       _refreshData();
//     });
//   }

//   void _deleteFoodItems(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const DeleteFoodsPage()),
//     ).then((_) {
//       _refreshData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Главная'),
//         actions: [
//           if (_isAdmin)
//             Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () => _addFoodItem(context),
//                   tooltip: 'Добавить товар',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () => _editFoodItems(context),
//                   tooltip: 'Редактировать товары',
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () => _deleteFoodItems(context),
//                   tooltip: 'Удалить товары',
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         key: _refreshIndicatorKey,
//         onRefresh: _refreshData,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _foodList.isEmpty
//                 ? const Center(
//                     child: SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.fastfood, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text(
//                             'Нет данных о товарах',
//                             style: TextStyle(fontSize: 18, color: Colors.grey),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Потяните вниз для обновления',
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: _foodList.length,
//                     itemBuilder: (context, index) {
//                       return CardPage(
//                         id: _foodList[index]['id'] ?? '',
//                         name: _foodList[index]['name'] ?? 'Без названия',
//                         imageUrl: _foodList[index]['image'] ?? '',
//                         price: _foodList[index]['price'] ?? 0,
//                         discount: _foodList[index]['discount'] ?? 0.0,
//                         description: _foodList[index]['description'] ?? '',
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }