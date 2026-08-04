import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 16, color: Colors.black12),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 12, color: Colors.black12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: List.generate(4, (index) => Container(decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)))),
          ),
          const SizedBox(height: 32),
          Container(width: 120, height: 20, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) => Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle))),
          ),
          const SizedBox(height: 32),
          Container(width: 120, height: 20, color: Colors.black12),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              height: 70,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
