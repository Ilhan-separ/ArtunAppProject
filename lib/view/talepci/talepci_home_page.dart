import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/view/talepci/kan_talep_page.dart';
import 'package:artun_flutter_project/view/talepci/talepci_talepler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../utilities/app_state_maneger.dart';

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
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.black,
              ),
              color: Colors.black,
              onPressed: () {
                Provider.of<AppStateManager>(context, listen: false).logout();
              },
            )
          ],
          title: Text(
            "Talepci Ekranı",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: IndexedStack(
          index: widget.currentTab,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.currentTab,
          surfaceTintColor: Colors.transparent,
          height: MediaQuery.of(context).size.height * .09,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onDestinationSelected: (index) {
            Provider.of<AppStateManager>(context, listen: false)
                .navigateTalebciTab(index);
          },
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: "Talepler",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.playlist_add_circle_sharp),
              icon: Icon(Icons.playlist_add_circle_outlined),
              label: "Kan Talep ",
            ),
          ],
        ),
      ),
    );
  }
}
