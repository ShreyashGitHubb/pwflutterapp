import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Real-time stream of crowd density data.
  Stream<QuerySnapshot> getCrowdFlowStream() {
    return _db.collection('stadium_telemetry').snapshots();
  }

  /// Updates user location for real-time routing.
  Future<void> updateUserLocation(String userId, double lat, double lng) async {
    await _db.collection('users').doc(userId).set({
      'location': GeoPoint(lat, lng),
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Logs an entry scan event to be consumed by The Oracle Agent.
  Future<void> logEntryScan(String gateId, int count) async {
    await _db.collection('scan_logs').add({
      'gate_id': gateId,
      'count': count,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches context for the Concierge Agent.
  Future<Map<String, dynamic>> getUserContext(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }
}
