import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/general_providers.dart';

import 'custom_exception.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  Future<void> signInAnonymous();
  User? getCurrentUser();
  Future<void> signOut();
}

class AuthRepository implements BaseAuthRepository {
  final Reader _reader;

  const AuthRepository(this._reader);

  @override
  Stream<User?> get authStateChanges =>
      _reader(firebaseAuthProvider).authStateChanges();

  @override
  User? getCurrentUser() {
    try {
      return _reader(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signInAnonymous() async {
    try {
      await _reader(firebaseAuthProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _reader(firebaseAuthProvider).signOut();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
