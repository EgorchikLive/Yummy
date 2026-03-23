// Альтернативная версия collapsible_orders_section.dart
import 'package:flutter/material.dart';
import 'orders_list.dart';

class CollapsibleOrdersSection extends StatefulWidget {
  final bool isDark;
  const CollapsibleOrdersSection({super.key, required this.isDark});

  @override
  State<CollapsibleOrdersSection> createState() => _CollapsibleOrdersSectionState();
}

class _CollapsibleOrdersSectionState extends State<CollapsibleOrdersSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Кнопка-заголовок для сворачивания
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.orange),
                const SizedBox(width: 12),
                const Text(
                  'История заказов',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  _getOrderCountText(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Анимированное содержимое
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OrdersList(isDark: widget.isDark),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _getOrderCountText() {
    // Здесь можно добавить логику получения количества заказов через StreamBuilder
    // Для простоты можно вернуть пустую строку или реализовать отдельный стрим
    return '';
  }
}