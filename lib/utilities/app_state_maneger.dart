import 'dart:async';

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

  bool get isInitialied => _initialized;
  bool get isKLoggedIn => _kloggedIn;
  bool get isTLoggedIn => _tloggedIn;
  int get getKizilaySelectedTab => _kizilaySelectedTab;
  int get getTalepciSelectedTab => _talepciSelectedTab;

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
    _kloggedIn = true;
    notifyListeners();
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

    initializedApp();
    notifyListeners();
  }
}
