import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final double growth;
  final double drawdown;
  final String status;

  const HealthCard({
    super.key,
    required this.growth,
    required this.drawdown,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.blue;

    switch (status.toLowerCase()) {
      case "excellent":
        statusColor = Colors.green;
        break;

      case "good":
        statusColor = Colors.lightGreen;
        break;

      case "normal":
        statusColor = Colors.orange;
        break;

      case "warning":
        statusColor = Colors.red;
        break;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "ACCOUNT HEALTH",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                healthItem(
                  "Growth",
                  "${growth.toStringAsFixed(2)}%",
                  Icons.trending_up,
                ),

                healthItem(
                  "Drawdown",
                  "${drawdown.toStringAsFixed(2)}%",
                  Icons.trending_down,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget healthItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon),

        const SizedBox(height: 8),

        Text(title),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}