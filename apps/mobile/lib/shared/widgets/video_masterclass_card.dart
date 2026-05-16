import 'package:flutter/material.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class VideoMasterclassCard extends StatelessWidget {
  const VideoMasterclassCard({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SaxCard(
      child: Column(
        children: [
          const Icon(Icons.video_library_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text('فيديو يوتيوب (يظهر في نسخة الموبايل)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
