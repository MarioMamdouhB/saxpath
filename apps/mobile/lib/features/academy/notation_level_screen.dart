import 'package:flutter/material.dart';
import 'package:saxpath_mobile/core/routing/stage_route_registry.dart';
import 'package:saxpath_mobile/core/theme/app_colors.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/widgets/notation_step_card.dart';
import 'package:saxpath_mobile/shared/widgets/section_title.dart';

class NotationLevelScreen extends StatelessWidget {
  const NotationLevelScreen({
    super.key,
    required this.levelTitle,
    required this.modules,
    required this.apiClient,
  });

  final String levelTitle;
  final List<NotationModuleData> modules;
  final SaxPathApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(levelTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionTitle(
            title: levelTitle,
            subtitle: 'تدرج من فهم الرموز إلى العزف الكامل على الساكسفون.',
          ),
          const SizedBox(height: 16),
          for (final module in modules) ...[
            _ModuleSection(module: module, apiClient: apiClient),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class NotationModuleData {
  final String title;
  final List<NotationLessonData> lessons;

  NotationModuleData({required this.title, required this.lessons});
}

class NotationLessonData {
  final String title;
  final String description;
  final String? noteLabel;
  final bool isCompleted;

  NotationLessonData({
    required this.title,
    required this.description,
    this.noteLabel,
    this.isCompleted = false,
  });
}

class _ModuleSection extends StatelessWidget {
  final NotationModuleData module;
  final SaxPathApiClient apiClient;

  const _ModuleSection({required this.module, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepTeal),
        ),
        const SizedBox(height: 12),
        for (final lesson in module.lessons) ...[
          NotationStepCard(
            title: lesson.title,
            description: lesson.description,
            noteLabel: lesson.noteLabel,
            isCompleted: lesson.isCompleted,
            onStart: () {
              // V3.1 Drill Integration
              StageRouteRegistry.navigateToStage(
                context,
                'first_notes', // Redirect to matching practical stage
                apiClient: apiClient,
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
