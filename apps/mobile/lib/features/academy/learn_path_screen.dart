import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/routing/stage_route_registry.dart';
import 'package:saxpath_mobile/data/models/track.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'widgets/learning_path_node.dart';

class LearnPathScreen extends StatelessWidget {
  const LearnPathScreen({super.key, required this.apiClient});

  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('أكاديمية الساكسفون', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepTeal,
      ),
      body: FutureBuilder<List<Track>>(
        future: apiClient.getTracks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tracks = snapshot.data!;
          final allStages = tracks.expand((t) => t.stages).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 60),
            itemCount: allStages.length,
            itemBuilder: (context, index) {
              final stage = allStages[index];

              // Zig-zag logic
              double horizontalOffset = 0.0;
              if (index % 4 == 1) {
                horizontalOffset = 60.0;
              } else if (index % 4 == 2) {
                horizontalOffset = 0.0;
              } else if (index % 4 == 3) {
                horizontalOffset = -60.0;
              }

              return Column(
                children: [
                  Transform.translate(
                    offset: Offset(horizontalOffset, 0),
                    child: LearningPathNode(
                      title: stage.title,
                      isLocked: !stage.isUnlocked,
                      isCompleted: stage.isCompleted,
                      isCurrent: stage.isUnlocked && !stage.isCompleted,
                      isExam: stage.isExam,
                      onTap: () => StageRouteRegistry.navigateToStage(
                        context,
                        stage.id,
                        apiClient: apiClient
                      ),
                    ),
                  ),
                  if (index < allStages.length - 1)
                    _buildAnimatedConnector(index),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedConnector(int index) {
    // Determine curve direction based on zig-zag
    bool isStraight = index % 2 == 0;

    return Container(
      height: 70,
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomPaint(
        painter: _PathConnectorPainter(isStraight: isStraight),
      ),
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  final bool isStraight;
  _PathConnectorPainter({required this.isStraight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isStraight) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      // Simple curve for zig-zag
      path.moveTo(size.width / 2, 0);
      path.quadraticBezierTo(size.width * 0.8, size.height / 2, size.width / 2, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
