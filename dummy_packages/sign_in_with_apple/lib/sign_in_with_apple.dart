library sign_in_with_apple;

// Dummy Apple sign-in interface
class SignInWithApple {
  static Future<_DummyAppleIDCredential> getAppleIDCredential({
    required List<dynamic> scopes,
    String? nonce,
  }) async {
    // Return a dummy credential instead of throwing
    return _DummyAppleIDCredential();
  }
}

class AppleIDAuthorizationScopes {
  static const email = 'email';
  static const fullName = 'fullName';
}

// Dummy class to simulate Apple ID credential
class _DummyAppleIDCredential {
  final String identityToken = 'dummy_token';
  final String authorizationCode = 'dummy_code';
}
