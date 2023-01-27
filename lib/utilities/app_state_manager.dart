import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KizilayTab {
  static const int talep = 0;
  static const int stok = 1;
}

class TalepciTab {
  static const int talepDetayi = 0;
  static const int talepEtme = 1;
}

class AppStateManager extends ChangeNotifier {
  bool _initialized = false;
  bool _kloggedIn = false;
  bool _tloggedIn = false;
  int _kizilaySelectedTab = KizilayTab.talep;
  int _talepciSelectedTab = TalepciTab.talepDetayi;
  String _currentUser = "aynen";
  bool _throwLoginAlert = false;

  bool get isInitialied => _initialized;
  bool get isKLoggedIn => _kloggedIn;
  bool get isTLoggedIn => _tloggedIn;
  int get getKizilaySelectedTab => _kizilaySelectedTab;
  int get getTalepciSelectedTab => _talepciSelectedTab;
  String get getCurrentUser => _currentUser;
  bool get isLoginThrowAlert => _throwLoginAlert;

  void initializedApp() {
    Timer(
      const Duration(milliseconds: 2500),
      () {
        _initialized = true;
        notifyListeners();
      },
    );
  }

  void loginForK(String username, String password) {
    Map<String, dynamic> data;
    FirebaseFirestore.instance.collection("KizilayUsers").get().then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (username == data["name"]) {
          _currentUser = data["id"];
          _throwLoginAlert = false;
          _kloggedIn = true;
          notifyListeners();
        }
      });
      if (_currentUser.contains("a")) {
        _throwLoginAlert = true;
        notifyListeners();
      }
    });
  }

  void loginForT(String username, String password) {
    _tloggedIn = true;
    notifyListeners();
  }

  void navigateKizilayTab(index) {
    _kizilaySelectedTab = index;
    notifyListeners();
  }

  void navigateTalebciTab(index) {
    _talepciSelectedTab = index;
    notifyListeners();
  }

  void logout() {
    _kloggedIn = false;
    _tloggedIn = false;
    _kizilaySelectedTab = 0;
    _talepciSelectedTab = 0;
    _currentUser = "aynen";

    initializedApp();
    notifyListeners();
  }
}
