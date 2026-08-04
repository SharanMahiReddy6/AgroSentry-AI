import 'package:flutter/material.dart';

class RecentScanCard extends StatelessWidget {
  final String cropName;
  final String result;
  final String date;
  final bool isHealthy;

  const RecentScanCard({
    super.key,
    required this.cropName,
    required this.result,
    required this.date,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isHealthy ? Colors.green : Colors.red;

    return Semantics(
      label: 'Scan result for $cropName: $result on $date',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
          ),
          title: Text(
            cropName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
