import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  final bool isDark;

  const OrderCard({
    super.key,
    required this.orderData,
    required this.orderId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = orderData['createdAt'];
    final date = timestamp is Timestamp
        ? DateFormat('dd.MM.yyyy HH:mm').format(timestamp.toDate())
        : '—';

    final total = double.tryParse(orderData['total']?.toString() ?? '0') ?? 0.0;
    final status = (orderData['status'] ?? 'unknown').toString();
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, date, total, status),
            const Divider(height: 20),
            _buildItemsList(items),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String date, double total, String status) {
    final statusColor = _getStatusColor(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заказ #$orderId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${total.toStringAsFixed(2)} ₽',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Text(
        'Нет товаров в заказе',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final name = item['name']?.toString() ?? 'Без названия';
        final imageUrl = item['imageUrl']?.toString() ?? '';
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
        final quantity =
            (item['quantity'] is num) ? item['quantity'] as num : 1;
        final total = price * quantity;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _buildItemImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${quantity.toInt()} × ${price.toStringAsFixed(2)} ₽',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Выполнен';
      case 'processing':
        return 'В обработке';
      case 'cancelled':
        return 'Отменён';
      default:
        return 'Неизвестен';
    }
  }
}
