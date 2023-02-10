import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/view/talepci/kan_talep_page.dart';
import 'package:artun_flutter_project/view/talepci/talepci_talepler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../utilities/app_state_manager.dart';

class THomePage extends StatefulWidget {
  static MaterialPage page(int currentTab) {
    return MaterialPage(
        name: AppPages.tHome,
        key: ValueKey(AppPages.tHome),
        child: THomePage(
          currentTab: currentTab,
        ));
  }

  const THomePage({
    Key? key,
    required this.currentTab,
  }) : super(key: key);

  final int currentTab;

  @override
  State<THomePage> createState() => _THomePageState();
}

class _THomePageState extends State<THomePage> {
  static List<Widget> pages = <Widget>[
    const TalepciTaleplerPage(),
    const KanTalepScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, tabManager, child) => Scaffold(
        appBar: AppBar(
          elevation: .5,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.grey[100],
          actions: [
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: projectRed,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Çıkış"),
                  onTap: () async {
                    Provider.of<AppStateManager>(context, listen: false)
                        .logout();
                  },
                )
              ],
            ),
          ],
          title: Text(
            Provider.of<AppStateManager>(context, listen: false)
                .getCurrentUserName,
            style: TextStyle(
              color: projectRed,
            ),
          ),
        ),
        body: IndexedStack(
          index: widget.currentTab,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.currentTab,
          surfaceTintColor: projectRed,
          shadowColor: Colors.white,
          height: MediaQuery.of(context).size.height * .09,
          elevation: .5,
          backgroundColor: Colors.grey[100],
          onDestinationSelected: (index) {
            Provider.of<AppStateManager>(context, listen: false)
                .navigateTalebciTab(index);
          },
          destinations: [
            NavigationDestination(
              selectedIcon: SvgPicture.asset("assets/ic_home_heart.svg"),
              icon: SvgPicture.asset("assets/ic_home_heart_outline.svg"),
              label: "Talepler",
            ),
            NavigationDestination(
              selectedIcon: SvgPicture.asset("assets/ic_heart_add.svg"),
              icon: SvgPicture.asset("assets/ic_heart_add_outline.svg"),
              label: "Kan Talep ",
            ),
          ],
        ),
      ),
    );
  }
}
