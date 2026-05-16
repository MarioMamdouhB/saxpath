import 'package:flutter/material.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/academy/jazz_academy_screen.dart';
import 'package:saxpath_mobile/features/academy/mvp_curriculum_screen.dart';
import 'package:saxpath_mobile/features/academy/maqam_lab_screen.dart';
import 'package:saxpath_mobile/features/academy/notation_level_screen.dart';
import 'package:saxpath_mobile/features/academy/scale_lab_screen.dart';
import 'package:saxpath_mobile/features/atlas/sax_atlas_screen.dart';
import 'package:saxpath_mobile/features/foundation/sax_foundation_screen.dart';

class StageRouteRegistry {
  static void navigateToStage(BuildContext context, String stageId, {required SaxPathApiClient apiClient}) {
    final route = _mapStageToWidget(stageId, apiClient: apiClient);

    if (route != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => route),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('المرحلة $stageId قيد التطوير قريباً!')),
      );
    }
  }

  static Widget? _mapStageToWidget(String stageId, {required SaxPathApiClient apiClient}) {
    // Map server-side IDs to actual Flutter screens
    switch (stageId) {
      case 'setup':
      case 'first_notes':
      case 'rhythm_basics':
      case 'rhythm_intro': // Added to match backend
        return const SaxFoundationScreen();
      case 'octave_mastery':
      case 'octave_intro': // Added to match backend
      case 'jazz_articulation':
      case 'scales_all':
      case 'scales_intro': // Added to match backend
      case 'swing_feel':
      case 'blues_basics':
        return JazzAcademyScreen(apiClient: apiClient);
      case 'altissimo':
      case 'improv_complex':
      case 'maqam_pro':
        return JazzAcademyScreen(apiClient: apiClient); // Advanced tracks use Jazz Academy framework
      case 'mvp_30_day':
        return MvpCurriculumScreen();
      case 'notation_beginner':
        return _buildNotationBeginner(apiClient);
      case 'sax_atlas':
        return const SaxAtlasScreen();
      case 'scale_lab':
        return const ScaleLabScreen();
      case 'maqam_lab':
        return const MaqamLabScreen();
      default:
        return null;
    }
  }

  static Widget _buildNotationBeginner(SaxPathApiClient apiClient) {
    return NotationLevelScreen(
      apiClient: apiClient,
      levelTitle: 'مستوى النوتة: مبتدئ',
      modules: [
        NotationModuleData(
          title: 'الوحدة 1: أساسيات المدرج',
          lessons: [
            NotationLessonData(title: 'الخطوط والمسافات', description: 'كيف نقرأ السلم من الأسفل للأعلى.'),
            NotationLessonData(title: 'مفتاح صول (Treble Clef)', description: 'لماذا يبدأ الساكسفون دائماً بهذا الرمز؟'),
          ],
        ),
        NotationModuleData(
          title: 'الوحدة 2: النغمات الأولى',
          lessons: [
            NotationLessonData(title: 'نغمة صول (G)', description: 'مكانها على الخط الثاني.', noteLabel: 'G4'),
            NotationLessonData(title: 'نغمة لا (A)', description: 'مكانها في المسافة الثانية.', noteLabel: 'A4'),
            NotationLessonData(title: 'نغمة سي (B)', description: 'مكانها على الخط الثالث.', noteLabel: 'B4'),
          ],
        ),
        NotationModuleData(
          title: 'الوحدة 3: النبض والوقت',
          lessons: [
            NotationLessonData(title: 'العد 1 2 3 4', description: 'تثبيت النبض الداخلي مع الميترونوم.'),
            NotationLessonData(title: 'الدخول القوي', description: 'كيف تبدأ عزفك مع أول دقة.'),
          ],
        ),
        NotationModuleData(
          title: 'الوحدة 4: قيم النغمات',
          lessons: [
            NotationLessonData(title: 'النوار (Quarter Note)', description: 'النغمة السوداء التي تستغرق عدة واحدة.', noteLabel: 'G4'),
            NotationLessonData(title: 'البلانش (Half Note)', description: 'النغمة البيضاء التي تستغرق عدتين.', noteLabel: 'G4'),
            NotationLessonData(title: 'المستديرة (Whole Note)', description: 'نغمة النفس الطويل (4 عدات).', noteLabel: 'G4'),
          ],
        ),
        NotationModuleData(
          title: 'الوحدة 5: لغة الصمت (السكتات)',
          lessons: [
            NotationLessonData(title: 'سكتة النوار', description: 'لحظة صمت بقدر دقة واحدة.'),
            NotationLessonData(title: 'سكتة البلانش', description: 'صمت طويل بقدر عدتين.'),
          ],
        ),
        NotationModuleData(
          title: 'الوحدة 6: أولى جمل القراءة',
          lessons: [
            NotationLessonData(title: 'تبديل G - A', description: 'قراءة وعزف نغمتين مختلفتين.', noteLabel: 'G4 A4'),
            NotationLessonData(title: 'تمرين الـ 3 نغمات', description: 'أول سطر موسيقي كامل من كتاب Rubank.', noteLabel: 'B4 A4 G4'),
          ],
        ),
      ],
    );
  }
}
