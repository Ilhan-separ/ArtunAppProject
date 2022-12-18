import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/model/app_state_maneger.dart';
import 'package:artun_flutter_project/pages/kizilay/Khome_page.dart';
import 'package:artun_flutter_project/pages/login.dart';
import 'package:artun_flutter_project/pages/splash.dart';
import 'package:flutter/material.dart';

class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppStateManager appStateManager;

  AppRouter({
    required this.appStateManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    appStateManager.addListener(notifyListeners);
    // daha fazla eklenebilir.
  }

  @override
  void dispose() {
    appStateManager.removeListener(notifyListeners);
    //daha fazla eklenebilir.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      //sayfa geçiş ayarları
      pages: [
        if (!appStateManager.isInitialied) SplashScreen.page(),
        if (appStateManager.isInitialied && !appStateManager.isLoggedIn)
          LoginPage.page(),
        if (appStateManager.isLoggedIn)
          KhomePage.page(appStateManager.getSelectedTab),
      ],
    );
  }

  bool _handlePopPage(Route<dynamic> route, result) {
    if (!route.didPop(result)) {
      return false;
    }
    return true;
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
