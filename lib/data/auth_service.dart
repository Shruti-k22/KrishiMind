import 'package:firebase_auth/firebase_auth.dart';

/// Everything to do with accounts, in one place.
///
/// Firebase stores the accounts and the passwords. The password is **encrypted
/// by Google** — it never passes through our code in a readable form and we
/// could not read it even if we wanted to. That is the whole reason to use
/// Firebase rather than storing passwords ourselves: storing passwords safely is
/// genuinely hard and easy to get dangerously wrong.
class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

  /// The signed-in user, or null if nobody is signed in.
  static User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => _auth.currentUser != null;

  // There was an accountExists() method here, asking Firebase whether an email
  // was already registered. It has been removed for two reasons. It was never
  // called — signInOrCreate handles both cases in one action, so nothing needed
  // to ask in advance. And Firebase has deprecated that lookup on purpose: being
  // able to ask "is this email registered?" lets a stranger test a list of
  // addresses and learn who uses the app. Not answering that question is the
  // safer design.

  /// Signs in if the account exists, creates it if it doesn't.
  ///
  /// One method for both, because from the farmer's point of view it is one
  /// action: "let me in". Returns null on success, or a message key describing
  /// what went wrong.
  static Future<AuthResult> signInOrCreate({
    required String email,
    required String password,
  }) async {
    final e = email.trim();
    try {
      await _auth.signInWithEmailAndPassword(email: e, password: password);
      return AuthResult.signedIn;
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        // No account yet — create one. This is the normal first-time path.
        case 'user-not-found':
        case 'invalid-credential':
          try {
            await _auth.createUserWithEmailAndPassword(
              email: e,
              password: password,
            );
            return AuthResult.created;
          } on FirebaseAuthException catch (err2) {
            if (err2.code == 'email-already-in-use') {
              // The account does exist, so the password was simply wrong.
              return AuthResult.wrongPassword;
            }
            if (err2.code == 'weak-password') return AuthResult.weakPassword;
            if (err2.code == 'invalid-email') return AuthResult.invalidEmail;
            if (err2.code == 'network-request-failed') {
              return AuthResult.noInternet;
            }
            return AuthResult.unknown;
          }

        case 'wrong-password':
          return AuthResult.wrongPassword;
        case 'invalid-email':
          return AuthResult.invalidEmail;
        case 'too-many-requests':
          return AuthResult.tooManyAttempts;
        case 'network-request-failed':
          return AuthResult.noInternet;
        default:
          return AuthResult.unknown;
      }
    } catch (_) {
      return AuthResult.unknown;
    }
  }

  /// Sends a password reset link to the email.
  static Future<bool> sendResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> signOut() => _auth.signOut();
}

enum AuthResult {
  signedIn,
  created,
  wrongPassword,
  invalidEmail,
  weakPassword,
  tooManyAttempts,
  noInternet,
  unknown,
}
