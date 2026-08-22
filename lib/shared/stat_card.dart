import 'package:flutter/material.dart';

/// Kartu statistik generik (icon opsional + judul + nilai besar),
/// dipakai berulang di `StatisticGrid` pada Dashboard untuk menampilkan
/// angka-angka ringkas (total trade, win rate, dst). [onTap] opsional
/// kalau kartunya perlu bisa ditekan. [color] mewarnai badge icon dan
/// nilainya supaya tiap kartu gampang dibedakan sekilas.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.onTap,
    this.color = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
              ],

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),

              // Mengisi ruang kosong secara otomatis
              const Spacer(),

              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
