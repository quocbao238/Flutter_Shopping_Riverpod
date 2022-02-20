import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomException implements Exception {
  final String? message;

  CustomException({this.message});

  @override
  String toString() {
    return 'Custom Exception { message :$message }';
  }
}
