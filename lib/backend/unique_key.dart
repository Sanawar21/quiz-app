import 'package:flutter/cupertino.dart';

String get key {
  String newKey = UniqueKey().toString();
  var alphabets = "abcdefghijklmnopqrstuvwxyz";
  var keyChars = [];
  var chars = newKey.split('');
  for (var char in chars) {
    if (alphabets.contains(char) ||
        alphabets.toUpperCase().contains(char) ||
        "0123456789".contains(char)) {
      keyChars.add(char);
    }
  }
  return keyChars.join();
}
