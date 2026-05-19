import 'disease.dart';
import 'disease_database.dart';
import 'ml_config.dart';

/// One ML class entry for the reference browser (excludes background).
class MlDiseaseEntry {
  final int mlIndex;
  final Disease disease;
  final String crop;

  const MlDiseaseEntry({
    required this.mlIndex,
    required this.disease,
    required this.crop,
  });
}

/// Background / non-leaf class — not shown in the disease encyclopedia.
const int mlBackgroundClassIndex = MlConfig.backgroundClassIndex;

/// Total output classes from the TFLite model (including background).
int get mlTotalClassCount => mlDiseaseMap.length;

/// Detectable plant classes shown in the reference browser.
int get mlDetectableClassCount => mlDiseaseCatalog.length;

/// Crop label for a model class index (e.g. scan results).
String cropNameForMlIndex(int index) => _cropByMlIndex[index] ?? 'Unknown';

const Map<int, String> _cropByMlIndex = {
  0: 'Apple',
  1: 'Apple',
  2: 'Apple',
  3: 'Apple',
  4: 'Blueberry',
  5: 'Cherry',
  6: 'Cherry',
  7: 'Corn',
  8: 'Corn',
  9: 'Corn',
  10: 'Corn',
  11: 'Grape',
  12: 'Grape',
  13: 'Grape',
  14: 'Grape',
  15: 'Orange',
  16: 'Peach',
  17: 'Peach',
  18: 'Pepper',
  19: 'Pepper',
  20: 'Potato',
  21: 'Potato',
  22: 'Potato',
  23: 'Raspberry',
  24: 'Soybean',
  25: 'Squash',
  26: 'Strawberry',
  27: 'Strawberry',
  28: 'Tomato',
  29: 'Tomato',
  30: 'Tomato',
  31: 'Tomato',
  32: 'Tomato',
  33: 'Tomato',
  34: 'Tomato',
  35: 'Tomato',
  36: 'Tomato',
  37: 'Tomato',
};

const List<String> cropDisplayOrder = [
  'Apple',
  'Blueberry',
  'Cherry',
  'Corn',
  'Grape',
  'Orange',
  'Peach',
  'Pepper',
  'Potato',
  'Raspberry',
  'Soybean',
  'Squash',
  'Strawberry',
  'Tomato',
];

/// All ML diseases except background, sorted by model class index.
List<MlDiseaseEntry> get mlDiseaseCatalog {
  final entries = <MlDiseaseEntry>[];
  for (final index in mlDiseaseMap.keys) {
    if (index == mlBackgroundClassIndex) continue;
    entries.add(
      MlDiseaseEntry(
        mlIndex: index,
        disease: mlDiseaseMap[index]!,
        crop: _cropByMlIndex[index] ?? 'Other',
      ),
    );
  }
  entries.sort((a, b) => a.mlIndex.compareTo(b.mlIndex));
  return entries;
}

/// Catalog grouped by crop for sectioned list UIs.
Map<String, List<MlDiseaseEntry>> get mlDiseasesGroupedByCrop {
  final grouped = <String, List<MlDiseaseEntry>>{};
  for (final entry in mlDiseaseCatalog) {
    grouped.putIfAbsent(entry.crop, () => []).add(entry);
  }

  final ordered = <String, List<MlDiseaseEntry>>{};
  for (final crop in cropDisplayOrder) {
    final list = grouped[crop];
    if (list != null && list.isNotEmpty) {
      ordered[crop] = list;
    }
  }
  for (final crop in grouped.keys) {
    if (!ordered.containsKey(crop)) {
      ordered[crop] = grouped[crop]!;
    }
  }
  return ordered;
}
