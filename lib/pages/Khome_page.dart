import 'package:flutter/material.dart';

class KhomePage extends StatelessWidget {
  const KhomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              TalepContainer(context, "Talepler"),
              TalepContainer(context, "Kan Stoğu"),
              TalepContainer(context, "Selam"),
            ],
          )),
    );
  }

  Widget TalepContainer(context, String ColumnTitle) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.width * 82,
      margin: EdgeInsets.all(2.0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        color: Color.fromARGB(255, 135, 170, 199),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(12)),
          Text(
            ColumnTitle,
            style: TextStyle(color: Colors.black, fontSize: 20),
          )
        ],
      ),
    );
  }
}
