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
  String _currentUserID = "";
  String _currentUserName = "";
  bool _throwLoginAlert = false;

  bool get isInitialied => _initialized;
  bool get isKLoggedIn => _kloggedIn;
  bool get isTLoggedIn => _tloggedIn;
  int get getKizilaySelectedTab => _kizilaySelectedTab;
  int get getTalepciSelectedTab => _talepciSelectedTab;
  String get getCurrentUserID => _currentUserID;
  String get getCurrentUserName => _currentUserName;
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
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          _throwLoginAlert = false;
          _kloggedIn = true;
          notifyListeners();
        }
      });
      if (_currentUserID.contains("")) {
        _throwLoginAlert = true;
        notifyListeners();
      }
    });
  }

  void loginForT(String username, String password) {
    Map<String, dynamic> data;
    FirebaseFirestore.instance.collection("TalepciUsers").get().then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (username == data["name"]) {
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          _throwLoginAlert = false;
          _tloggedIn = true;
          notifyListeners();
        }
      });
      if (_currentUserID.contains("")) {
        _throwLoginAlert = true;
        notifyListeners();
      }
    });
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
    _throwLoginAlert = false;
    _currentUserID = "";
    _currentUserName = "";

    initializedApp();
    notifyListeners();
  }
}
