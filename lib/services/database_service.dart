import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/disease_catalog.dart';
import '../models/scan_result.dart';
import 'ml_service.dart';

class DatabaseService {
  static const String _databaseUrl =
      'https://agri-doctor-ea09c-default-rtdb.asia-southeast1.firebasedatabase.app';

  static FirebaseDatabase? _sharedDb;
  static bool _loggedInit = false;

  FirebaseDatabase get _db {
    _sharedDb ??= FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    );
    if (!_loggedInit) {
      debugPrint('[DatabaseService] database initialized: $_databaseUrl');
      _loggedInit = true;
    }
    return _sharedDb!;
  }

  String? _lastSaveKey;
  DateTime? _lastSaveAt;

  DatabaseReference _scansRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.ref('scans/$uid');
  }

  /// Saves a scan under scans/{uid}/{pushKey}.
  /// Skips background detections and rapid duplicate saves.
  Future<void> saveScan({
    required MLResult mlResult,
    required String scanSource,
    String? localImagePath,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (mlResult.isBackground) return;

    final fingerprint =
        '${mlResult.classIndex}_${mlResult.confidence.toStringAsFixed(3)}_$localImagePath';
    final now = DateTime.now();
    if (_lastSaveKey == fingerprint &&
        _lastSaveAt != null &&
        now.difference(_lastSaveAt!) < const Duration(seconds: 3)) {
      return;
    }

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
      'scannedAt': now.millisecondsSinceEpoch,
      'mlClassIndex': mlResult.classIndex,
      'cropName': cropNameForMlIndex(mlResult.classIndex),
    });

    _lastSaveKey = fingerprint;
    _lastSaveAt = now;
  }

  Stream<List<ScanResult>> getScanHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('[DatabaseService] no history found: not signed in');
      return Stream.value(<ScanResult>[]);
    }

    debugPrint('[DatabaseService] history fetch started');
    return _scansRef()
        .orderByKey()
        .limitToLast(50)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw == null) {
        debugPrint('[DatabaseService] no history found');
        return <ScanResult>[];
      }

      final entries = Map<String, dynamic>.from(raw as Map);
      final results = <ScanResult>[];

      for (final entry in entries.entries) {
        try {
          final data = Map<String, dynamic>.from(entry.value as Map);
          results.add(ScanResult.fromMap(entry.key, data));
        } catch (_) {
          // Skip corrupted or legacy records without a disease name.
        }
      }

      results.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      if (results.isEmpty) {
        debugPrint('[DatabaseService] no history found');
      } else {
        debugPrint('[DatabaseService] history loaded: ${results.length} scans');
      }
      return results;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('[DatabaseService] Firebase error: $error');
      throw error;
    });
  }

  Future<void> deleteScan(String scanKey) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.ref('scans/$uid/$scanKey').remove();
  }
}
