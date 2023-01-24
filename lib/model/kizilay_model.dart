import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Kizilay {
  final String? name;
  final String? konum;
  final Map<String, dynamic>? stok;

  Kizilay({required this.name, required this.konum, required this.stok});

  factory Kizilay.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Kizilay(
        name: data?['name'], konum: data?['konum'], stok: data?['kanStogu']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (konum != null) "konum": konum,
      if (stok != null) "stok": stok,
    };
  }
}
