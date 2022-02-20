import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/general_providers.dart';



class AuthController extends StateNotifier<User?> {
  final Reader _reader;

  StreamSubscription<User?>? _authStateChangeSubscription;

  AuthController(this._reader) : super(null) {
    _authStateChangeSubscription?.cancel();
    _authStateChangeSubscription =
        _reader(authRepositoryProvider).authStateChanges.listen((event) {
      state = event;
    });
  }

  @override
  void dispose() {
    _authStateChangeSubscription?.cancel();
    super.dispose();
  }

  void appStated() async {
    final user = _reader(authRepositoryProvider).getCurrentUser();
    if (user == null) await _reader(authRepositoryProvider).signInAnonymous();
  }

  void signOut() async {
    await _reader(authRepositoryProvider).signOut();
  }
}
