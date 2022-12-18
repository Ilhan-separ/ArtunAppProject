import 'dart:async';

import 'package:flutter/material.dart';

class AppTab {
  static const int talep = 0;
  static const int stok = 1;
  static const int map = 2;
}

class AppStateManager extends ChangeNotifier {
  bool _initialized = false;
  bool _loggedIn = false;
  int _selectedTab = AppTab.talep;

  bool get isInitialied => _initialized;
  bool get isLoggedIn => _loggedIn;
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

  void login(String username, String password) {
    _loggedIn = true;
    notifyListeners();
  }

  void goToTab(index) {
    _selectedTab = index;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _initialized = false;
    _selectedTab = 0;

    initializedApp();
    notifyListeners();
  }
}
