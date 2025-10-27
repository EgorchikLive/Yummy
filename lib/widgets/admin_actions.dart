import 'package:flutter/material.dart';
import 'package:yummy/pages/add_page.dart';
import 'package:yummy/pages/edit_foods_page.dart';
import 'package:yummy/pages/delete_foods_page.dart';

class AdminActions extends StatelessWidget {
  final VoidCallback onRefreshRequested;

  const AdminActions({super.key, required this.onRefreshRequested});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => onRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Добавить товар',
          onPressed: () => _navigate(context, const AddPage()),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Редактировать товары',
          onPressed: () => _navigate(context, const EditFoodsPage()),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Удалить товары',
          onPressed: () => _navigate(context, const DeleteFoodsPage()),
        ),
      ],
    );
  }
}
