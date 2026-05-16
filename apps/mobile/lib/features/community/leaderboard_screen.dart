import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text('أفضل العازفين (Leaderboard)')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: SectionTitle(
              title: 'منافسة العباقرة',
              subtitle: 'ترتيب عازفي الساكسفون بناءً على نقاط الخبرة (XP).',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildLeaderItem(1, 'محمود صبري', 12500, isMe: false),
                _buildLeaderItem(2, 'ياسين الموسيقي', 10200, isMe: false),
                _buildLeaderItem(3, 'سارة ساكس', 9800, isMe: false),
                const Divider(),
                _buildLeaderItem(42, 'أنت (أحمد)', 1250, isMe: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderItem(int rank, String name, int xp, {required bool isMe}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.softMint.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: TextStyle(fontWeight: isMe ? FontWeight.w900 : FontWeight.normal)),
        trailing: Text('$xp XP', style: const TextStyle(color: AppColors.deepTeal, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.muted;
  }
}
