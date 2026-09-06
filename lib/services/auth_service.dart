import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static Future<UserCredential> signIn(String email, String password) => _auth.signInWithEmailAndPassword(email: email, password: password);
  static Future<UserCredential> createAccount({required String email, required String password, required String displayName, required String accountType}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await _db.collection('users').doc(user.uid).set({
      'displayName': displayName, 'accountType': accountType, 'countryCode': '', 'photoUrl': '', 'bio': '', 'updatedAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }
  static Future<void> signOut() => _auth.signOut();

  static Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) throw StateError('Not signed in');
    await user.updateDisplayName(displayName);
    await _db.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
