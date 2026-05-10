import 'concept_to_music_service.dart';
import 'jazz_curriculum_models.dart';

class ConceptApplicationService {
  const ConceptApplicationService({
    ConceptToMusicService? conceptService,
  }) : conceptService = conceptService ?? const ConceptToMusicService();

  final ConceptToMusicService conceptService;

  List<ConceptToMusicMap> mapsForPillar(JazzPillarId pillarId) {
    return conceptService.mapsForPillar(pillarId);
  }

  List<ConceptToMusicMap> mapsForModule(String moduleId) {
    return conceptService.mapsForModule(moduleId);
  }

  ConceptToMusicMap? findById(String conceptId, JazzPillarId pillarId) {
    final maps = mapsForPillar(pillarId);
    for (final map in maps) {
      if (map.id == conceptId) {
        return map;
      }
    }
    return null;
  }
}
