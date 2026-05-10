import 'jazz_curriculum_models.dart';
import 'sax_foundation_models.dart' as foundation;

class SaxTranspositionService {
  const SaxTranspositionService();

  String? resolveKey({
    required SaxType saxType,
    String? concertKey,
    String? writtenKeyForBbSax,
    String? writtenKeyForEbSax,
  }) {
    return resolveKeyForSax(
      saxType,
      concertKey: concertKey,
      writtenKeyForBbSax: writtenKeyForBbSax,
      writtenKeyForEbSax: writtenKeyForEbSax,
    );
  }

  Map<String, String> buildSummary({
    String? concertKey,
    String? writtenKeyForBbSax,
    String? writtenKeyForEbSax,
  }) {
    return buildTranspositionSummary(
      concertKey: concertKey,
      writtenKeyForBbSax: writtenKeyForBbSax,
      writtenKeyForEbSax: writtenKeyForEbSax,
    );
  }

  String describe({
    required SaxType saxType,
    String? concertKey,
    String? writtenKeyForBbSax,
    String? writtenKeyForEbSax,
  }) {
    final key = resolveKey(
      saxType: saxType,
      concertKey: concertKey,
      writtenKeyForBbSax: writtenKeyForBbSax,
      writtenKeyForEbSax: writtenKeyForEbSax,
    );
    return '${saxTypeDisplayLabel(saxType)}: ${key ?? 'N/A'}';
  }

  String writtenToConcertPitch({
    required foundation.SaxType saxType,
    required String writtenPitch,
  }) {
    final written = foundation.noteNameFromLabel(writtenPitch);
    const noteValues = foundation.NoteName.values;
    final writtenIndex = noteValues.indexOf(written);
    final offset = switch (saxType) {
      foundation.SaxType.altoEb => 3,
      foundation.SaxType.baritoneEb => 3,
      foundation.SaxType.tenorBb => 10,
      foundation.SaxType.sopranoBb => 10,
    };
    final concertIndex = (writtenIndex + offset) % noteValues.length;
    return noteValues[concertIndex].label;
  }
}
