import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

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
  bool _kLoggedIn = false;
  bool _tLoggedIn = false;
  int _kizilaySelectedTab = KizilayTab.talep;
  int _talepciSelectedTab = TalepciTab.talepDetayi;
  String _currentUserID = "a";
  String _currentUserName = "";
  bool _throwLoginAlert = false;
  double _currentUserLat = 1;
  double _currentUserLng = 1;

  bool get isInitialied => _initialized;
  bool get isKLoggedIn => _kLoggedIn;
  bool get isTLoggedIn => _tLoggedIn;
  int get getKizilaySelectedTab => _kizilaySelectedTab;
  int get getTalepciSelectedTab => _talepciSelectedTab;
  String get getCurrentUserID => _currentUserID;
  String get getCurrentUserName => _currentUserName;
  bool get isLoginThrowAlert => _throwLoginAlert;
  double get getCurrentUserLat => _currentUserLat;
  double get getCurrentUserLng => _currentUserLng;

  void initializedApp() {
    Timer(
      const Duration(milliseconds: 2500),
      () {
        _initialized = true; //TODO: açılışta log işlemlerini yap.
        notifyListeners();
      },
    );
  }

  Future<void> loginForK(String username, String password) async {
    Map<String, dynamic> data;
    await FirebaseFirestore.instance
        .collection("KizilayUsers")
        .get()
        .then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (username == data["kullaniciAdi"] && password == data["password"]) {
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          // _currentUserLat = data["lat"];
          // _currentUserLng = data["lng"];
          _throwLoginAlert = false;
          SessionManager().set("id", _currentUserID);
          _kLoggedIn = true;
          notifyListeners();
        }
      });
    });
    if (_currentUserID.contains("a")) {
      _throwLoginAlert = true;
      notifyListeners();
    }
  }

  Future<void> loginForT(String username, String password) async {
    Map<String, dynamic> data;
    await FirebaseFirestore.instance
        .collection("TalepciUsers")
        .get()
        .then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (username == data["kullaniciAdi"] && password == data["password"]) {
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          _currentUserLat = data["lat"];
          _currentUserLng = data["lng"];
          _throwLoginAlert = false;
          SessionManager().set("id", _currentUserID);
          _tLoggedIn = true;
          notifyListeners();
        }
      });
    });
    if (_currentUserID.contains("a")) {
      _throwLoginAlert = true;
      notifyListeners();
    }
  }

  void _getKizilayData(String id) {
    Map<String, dynamic> data;
    FirebaseFirestore.instance.collection("KizilayUsers").get().then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (id == data["id"]) {
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          // _currentUserLat = data["lat"];
          // _currentUserLng = data["lng"];
          _throwLoginAlert = false;
          _kLoggedIn = true;
          notifyListeners();
        }
      });
    });
  }

  void _getTalepciData(String id) {
    Map<String, dynamic> data;
    FirebaseFirestore.instance.collection("TalepciUsers").get().then((query) {
      query.docs.forEach((element) {
        data = element.data() as Map<String, dynamic>;
        if (id == data["id"]) {
          _currentUserID = data["id"];
          _currentUserName = data["name"];
          _currentUserLat = data["lat"];
          _currentUserLng = data["lng"];
          _throwLoginAlert = false;
          _tLoggedIn = true;
          notifyListeners();
        }
      });
    });
  }

  Future<void> isAlreadyLogged() async {
    bool isLoggedIn = false;
    String user = "";
    await SessionManager().containsKey("id").then((value) {
      if (value != null) {
        isLoggedIn = value;
      } else {
        return false;
      }
    });
    await SessionManager().get("id").then((value) {
      if (value != null) {
        user = value;
      }
    });
    if (isLoggedIn) {
      if (user.contains("User")) {
        _getKizilayData(user);
      } else {
        _getTalepciData(user);
      }
    } else {
      _kLoggedIn = false;
      _tLoggedIn = false;
    }
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
    _kLoggedIn = false;
    _tLoggedIn = false;
    _kizilaySelectedTab = 0;
    _talepciSelectedTab = 0;
    _currentUserLat = 1;
    _currentUserLng = 1;
    _throwLoginAlert = false;
    _currentUserID = "";
    _currentUserName = "";
    SessionManager().destroy;

    initializedApp();
    notifyListeners();
  }
}
