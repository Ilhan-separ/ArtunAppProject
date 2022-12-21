import 'dart:async';

import 'package:flutter/material.dart';

class AppTab {
  static const int talep = 0;
  static const int stok = 1;
  static const int map = 2;
}

class AppStateManager extends ChangeNotifier {
  bool _initialized = false;
  bool _kloggedIn = false;
  bool _tloggedIn = false;
  int _selectedTab = AppTab.talep;

  bool get isInitialied => _initialized;
  bool get isKLoggedIn => _kloggedIn;
  bool get isTLoggedIn => _tloggedIn;
  int get getSelectedTab => _selectedTab;

  void initializedApp() {
    Timer(
      const Duration(milliseconds: 3000),
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

  void goToTab(index) {
    _selectedTab = index;
    notifyListeners();
  }

  void logout() {
    _kloggedIn = false;
    _tloggedIn = false;
    _initialized = false;
    _selectedTab = 0;

    initializedApp();
    notifyListeners();
  }
}
