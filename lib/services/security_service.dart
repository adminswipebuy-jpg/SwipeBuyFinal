import 'package:firebase_auth/firebase_auth.dart';

class SecurityService {
  SecurityService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      throw StateError('A signed-in email/password account is required.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccountAfterReauthentication(String password) async {
    await reauthenticateWithPassword(password);
    await _auth.currentUser!.delete();
  }
}
