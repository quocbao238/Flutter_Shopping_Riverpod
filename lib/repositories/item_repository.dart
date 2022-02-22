import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopping_riverpod/extensions/firebase_firestore_extension.dart';
import 'package:flutter_shopping_riverpod/general_providers.dart';
import 'package:flutter_shopping_riverpod/repositories/custom_exception.dart';

import '../models/item_model.dart';

abstract class BaseItemRepository {
  Future<List<Item>> retriveItems({required String userId});
  Future<String> createItem({required String userId, required Item item});
  Future<bool> updateItem({required String userId, required Item item});
  Future<bool> deleteItem({required String userId, required String itemId});
}

class ItemRepository implements BaseItemRepository {
  final Reader _reader;
  const ItemRepository(this._reader);

  @override
  Future<List<Item>> retriveItems({required String userId}) async {
    try {
      final snap = await _reader(firebaseFirestoreProvider)
          .collection('lists')
          .doc(userId)
          .collection('userList')
          .withConverter<Item>(
              fromFirestore: (snapshot, _) => Item.fromDocument(snapshot),
              toFirestore: (model, _) => model.toJson())
          .get();
      return snap.docs.map((e) => e.data()).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<String> createItem({
    required String userId,
    required Item item,
  }) async {
    try {
      final docRef = await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .add(item.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<bool> deleteItem(
      {required String userId, required String itemId}) async {
    bool _result = false;

    try {
      await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return _result;
  }

  @override
  Future<bool> updateItem({required String userId, required Item item}) async {
    bool _result = false;
    try {
      await _reader(firebaseFirestoreProvider)
          .userListRef(userId)
          .doc(item.id)
          .update(item.toDocument());
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return _result;
  }
}
