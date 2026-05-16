import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoMasterclassCard extends StatefulWidget {
  const VideoMasterclassCard({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  State<VideoMasterclassCard> createState() => _VideoMasterclassCardState();
}

class _VideoMasterclassCardState extends State<VideoMasterclassCard> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    // Only initialize YouTube on Mobile (Android/iOS)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (_videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback UI for Windows/Desktop or unsupported URLs
    if (_controller == null) {
      return SaxCard(
        child: Column(
          children: [
            const Icon(Icons.video_library_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('فيديو يوتيوب (متاح في نسخة الموبايل)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return SaxCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
