import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';

class GoogleAuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSigningIn => _isSigningIn;
  bool get isSignedIn => _currentUser != null;

  Future<void> initialize() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      notifyListeners();
    });
    
    // Try silent sign-in
    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Silent sign-in failed: $error');
      }
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle(UserService userService) async {
    try {
      _isSigningIn = true;
      notifyListeners();

      final account = await _googleSignIn.signIn();
      
      if (account != null) {
        _currentUser = account;
        
        // Register user in app if not exists
        final registered = await userService.register(
          username: account.displayName ?? 'User',
          email: account.email,
        );

        if (registered) {
          if (kDebugMode) {
            debugPrint('Google Sign-In successful: ${account.email}');
          }
        }
      }

      _isSigningIn = false;
      notifyListeners();
      return account;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Google Sign-In error: $error');
      }
      _isSigningIn = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Google Sign-Out error: $error');
      }
    }
  }
}
