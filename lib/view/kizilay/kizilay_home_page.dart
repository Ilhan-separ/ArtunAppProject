import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/mapMockup.dart';
import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:artun_flutter_project/view/details_page.dart';

import 'package:artun_flutter_project/view/kizilay/kan_stogu_page.dart';
import 'package:artun_flutter_project/view/kizilay/kizilay_talepler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class KhomePage extends StatefulWidget {
  static MaterialPage page(int currentTab) {
    return MaterialPage(
        name: AppPages.kHome,
        key: ValueKey(AppPages.kHome),
        child: KhomePage(
          currentTab: currentTab,
        ));
  }

  const KhomePage({
    Key? key,
    required this.currentTab,
  }) : super(key: key);

  final int currentTab;

  @override
  State<KhomePage> createState() => _KhomePageState();
}

class _KhomePageState extends State<KhomePage> {
  static List<Widget> pages = <Widget>[
    const KizilayTaleplerPage(),
    const KanStokPage(),
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
          title: const Text(
            "Kızılay Ekranı",
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
          height: MediaQuery.of(context).size.height * .09,
          elevation: 0,
          backgroundColor: projectRed,
          onDestinationSelected: (index) {
            Provider.of<AppStateManager>(context, listen: false)
                .navigateKizilayTab(index);
          },
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: "Talepler",
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.church_sharp),
              icon: Icon(Icons.church_outlined),
              label: "Kan Stoğu ",
            ),
          ],
        ),
      ),
    );
  }
}
