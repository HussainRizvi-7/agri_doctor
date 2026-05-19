import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/scan_result.dart';
import '../services/ml_service.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _scansRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.ref('scans/$uid');
  }

  /// Saves a scan result under scans/{uid}/{pushKey}.
  /// [scanSource] is 'camera' or 'gallery'.
  Future<void> saveScan({
    required MLResult mlResult,
    required String scanSource,
    String? localImagePath,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.ref('scans/$uid').push().set({
      'userId': uid,
      'diseaseName': mlResult.disease.name,
      'diseaseEmoji': mlResult.disease.iconEmoji,
      'severity': mlResult.disease.severity,
      'color': mlResult.disease.color,
      'description': mlResult.disease.description,
      'solution': mlResult.disease.solution,
      'confidence': mlResult.confidence,
      'localImagePath': localImagePath,
      'scanSource': scanSource,
      'scannedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Realtime stream of the 50 most-recent scans, newest first.
  /// Uses push-key ordering (chronological) then reverses client-side.
  Stream<List<ScanResult>> getScanHistory() {
    return _scansRef()
        .orderByKey()
        .limitToLast(50)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return <ScanResult>[];

      final entries = Map<String, dynamic>.from(raw as Map);
      final results = entries.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        return ScanResult.fromMap(e.key, data);
      }).toList();

      // Newest first
      results.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return results;
    });
  }

  /// Removes a single scan node.
  Future<void> deleteScan(String scanKey) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.ref('scans/$uid/$scanKey').remove();
  }
}
