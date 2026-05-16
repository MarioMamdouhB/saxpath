import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/features/progress/state/app_progress_scope.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppProgressScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('بطاقة العازف', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Player Header
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.deepTeal,
                  child: Icon(Icons.person_rounded, size: 60, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text('أحمد العازف', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('مستوى: مبتدئ متقدم', style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Stats Row
          Row(
            children: [
              _buildStatCard('أيام الالتزام', '${progress.currentStreakDays}', Icons.fireplace_rounded, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('نقاط الخبرة', '${progress.xpPoints}', Icons.star_rounded, Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          // Trophies section
          SaxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الأوسمة والميداليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildTrophy(Icons.music_note_rounded, 'صياد النغمات'),
                    _buildTrophy(Icons.timer_rounded, 'منضبط'),
                    _buildTrophy(Icons.language_rounded, 'ملك السيكا', isLocked: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Certificates
          SaxCard(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 40),
              title: const Text('شهادة المستوى المبتدئ', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('تم الحصول عليها في 12 مايو 2024'),
              trailing: const Icon(Icons.file_download_rounded, color: AppColors.deepTeal),
              onTap: () {
                // Open PDF Certificate
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: SaxCard(
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophy(IconData icon, String label, {bool isLocked = false}) {
    return Opacity(
      opacity: isLocked ? 0.3 : 1.0,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.blueGrey[50], shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.deepTeal),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
