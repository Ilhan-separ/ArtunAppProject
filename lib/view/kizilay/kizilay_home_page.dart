import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';

import 'package:artun_flutter_project/view/kizilay/kan_stogu_page.dart';
import 'package:artun_flutter_project/view/kizilay/kizilay_talepler_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
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

  Future<void> yazdir() async {
    print(await SessionManager().get("id"));
  }

  @override
  Widget build(BuildContext context) {
    yazdir();
    return Consumer<AppStateManager>(
      builder: (context, tabManager, child) => Scaffold(
        appBar: AppBar(
          elevation: .5,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.grey[100],
          leading: null,
          actions: [
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: projectRed,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Çıkış"),
                  onTap: () {
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
          height: MediaQuery.of(context).size.height * .09,
          elevation: .5,
          backgroundColor: Colors.grey[100],
          onDestinationSelected: (index) {
            Provider.of<AppStateManager>(context, listen: false)
                .navigateKizilayTab(index);
          },
          destinations: [
            NavigationDestination(
              selectedIcon: Icon(
                Icons.home,
                color: projectRed,
              ),
              icon: Icon(
                Icons.home_outlined,
                color: projectRed,
              ),
              label: "Talepler",
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.church_sharp,
                color: projectRed,
              ),
              icon: Icon(
                Icons.church_outlined,
                color: projectRed,
              ),
              label: "Kan Stoğu ",
            ),
          ],
        ),
      ),
    );
  }
}
