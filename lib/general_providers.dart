import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/controller/auth_controller.dart';
import 'package:flutter_shopping_riverpod/repositories/auth_repository.dart';
import 'package:flutter_shopping_riverpod/repositories/item_repository.dart';

import 'controller/item_list_controller.dart';
import 'models/item_model.dart';
import 'repositories/custom_exception.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(ref.read)..appStated();
});

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

final itemListExceptionProvider = StateProvider<CustomException?>((ref) {
  return null;
});

// final itemListExceptionProvider =
//     StateNotifierProvider<CustomException.state, String>((ref) {
//   return null;
// });

final itemListControllerProvider =
    StateNotifierProvider<ItemListController, AsyncValue<List<Item>>>((ref) {
  final user = ref.watch(authControllerProvider);
  return ItemListController(ref.read, user?.uid);
});
