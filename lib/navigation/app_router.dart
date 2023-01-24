import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/utilities/app_state_maneger.dart';
import 'package:artun_flutter_project/view/kizilay/kizilay_home_page.dart';
import 'package:artun_flutter_project/view/login.dart';
import 'package:artun_flutter_project/view/splash.dart';
import 'package:artun_flutter_project/view/talepci/talepci_home_page.dart';
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
        if (appStateManager.isInitialied &&
            !appStateManager.isKLoggedIn &&
            !appStateManager.isTLoggedIn)
          LoginPage.page(),
        if (appStateManager.isTLoggedIn)
          THomePage.page(appStateManager.getTalepciSelectedTab),
        if (appStateManager.isKLoggedIn)
          KhomePage.page(appStateManager.getKizilaySelectedTab),
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
