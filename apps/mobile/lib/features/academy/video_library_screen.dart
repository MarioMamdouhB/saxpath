import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';
import 'package:saxpath_mobile/shared/widgets/video_masterclass_card.dart';

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('مكتبة الساكسفون (YouTube)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionTitle(
            title: 'أفضل الشروحات العالمية',
            subtitle: 'تم انتقاء هذه الدروس بعناية لتناسب رحلة تعلمك.',
          ),
          const SizedBox(height: 20),
          _buildCategoryHeader('أساسيات للمبتدئين', Icons.rocket_launch_rounded),
          const VideoMasterclassCard(
            title: 'كيف تختار أول ساكسفون لك؟',
            videoUrl: 'https://www.youtube.com/watch?v=A8f9-4hV03U',
          ),
          const SizedBox(height: 16),
          const VideoMasterclassCard(
            title: 'وضعية الفم الصحيحة (Embouchure)',
            videoUrl: 'https://www.youtube.com/watch?v=0_uFfR7A6h4',
          ),
          const SizedBox(height: 24),
          _buildCategoryHeader('تقنيات احترافية', Icons.star_rounded),
          const VideoMasterclassCard(
            title: 'سر نغمة الساكسفون القوية',
            videoUrl: 'https://www.youtube.com/watch?v=f2n_zLzI5u0',
          ),
          const SizedBox(height: 16),
          const VideoMasterclassCard(
            title: 'تعلم الارتجال ببساطة',
            videoUrl: 'https://www.youtube.com/watch?v=Zf_DqOq2Yic',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepTeal, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepTeal),
          ),
        ],
      ),
    );
  }
}
