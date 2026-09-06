import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LearningCourseService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedCourses() {
    return _db.collection('learning_courses').where('published', isEqualTo: true).limit(100).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myEnrollments() {
    if (_uid.isEmpty) return const Stream.empty();
    return _db.collection('learning_enrollments').where('userId', isEqualTo: _uid).limit(100).snapshots();
  }

  Future<void> requestEnrollment({required String courseId}) async {
    if (_uid.isEmpty) return;
    await _db.collection('learning_enrollment_requests').add({
      'userId': _uid,
      'courseId': courseId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProgress({required String enrollmentId, required int percent}) async {
    if (_uid.isEmpty) return;
    await _db.collection('learning_progress_requests').add({
      'userId': _uid,
      'enrollmentId': enrollmentId,
      'percent': percent.clamp(0, 100),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestCertificate({required String enrollmentId}) async {
    if (_uid.isEmpty) return;
    await _db.collection('learning_certificate_requests').add({
      'userId': _uid,
      'enrollmentId': enrollmentId,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
