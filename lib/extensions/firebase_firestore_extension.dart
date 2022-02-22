import 'package:cloud_firestore/cloud_firestore.dart';

extension FirebaseFirestoreExtension on FirebaseFirestore {
  CollectionReference<Map<String, dynamic>> userListRef(String userId) =>
      collection('lists').doc(userId).collection('userList');
}
