import 'package:flutter/material.dart';

class TaleplerPage extends StatefulWidget {
  const TaleplerPage({super.key});

  @override
  State<TaleplerPage> createState() => _TaleplerPageState();
}

class _TaleplerPageState extends State<TaleplerPage> {
  List<String> listId = [
    "selam",
    "naber",
    "aynn",
    "çok şey yapma",
    "olur öyle",
    "falan denir",
    "xd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
              height: 12,
            ),
        padding: const EdgeInsets.all(8),
        itemCount: listId.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white, // Your desired background color
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 0.3),
                ]),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              leading: Icon(Icons.assignment),
              subtitle: Text("aman"),
              contentPadding: EdgeInsets.all(8),
              title: Text(listId[index]),
              trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text("Gönder"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFFF48634),
                    ),
                  )),
            ),
          );
        });
  }
}
