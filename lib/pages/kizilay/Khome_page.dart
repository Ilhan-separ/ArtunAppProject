import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/model/app_state_maneger.dart';
import 'package:artun_flutter_project/pages/map.dart';

import 'package:artun_flutter_project/pages/kizilay/kan_stogu_page.dart';
import 'package:artun_flutter_project/pages/kizilay/talepler_page.dart';
import 'package:flutter/material.dart';
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
    TaleplerPage(),
    KanStokPage(),
    MapPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, tabManager, child) => Scaffold(
        appBar: AppBar(
          elevation: 0.3,
          title: Text(
            "Artun App",
            style: TextStyle(
              color: Color(0xFFF343085),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: IndexedStack(
          index: widget.currentTab,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.currentTab,
          selectedItemColor: Color(0xFF343085),
          elevation: 2,
          onTap: (index) {
            Provider.of<AppStateManager>(context, listen: false).goToTab(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Talepler",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.church_sharp),
              label: "Kan Stoğu ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_sharp),
              label: "Map",
            ),
          ],
        ),
      ),
    );
  }

  Widget TalepContainer(context, String ColumnTitle, [int index = 0]) {
    return InkResponse(
      onTap: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width * 82,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF11112C),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: Color(0xFFF48634), width: 0.5),
            boxShadow: const [
              BoxShadow(
                // Koyu renk
                color: Color(0xFF06060F),
                offset: Offset(-1, 1),
                blurRadius: 2.5,
                spreadRadius: 1.0,
              ),
              BoxShadow(
                // Açık renk
                color: Color.fromARGB(
                    255, 27, 27, 70), //Color.fromARGB(255, 35, 35, 35),
                offset: Offset(1, -1),
                blurRadius: .8,
                spreadRadius: 1.0,
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ColumnTitle,
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
