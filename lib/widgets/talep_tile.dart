import 'package:artun_flutter_project/constants.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

class TalepTile extends StatelessWidget {
  final String talepEden;
  final String talepDetayi;
  final containerColor;

  const TalepTile(
      {super.key,
      required this.talepEden,
      required this.talepDetayi,
      this.containerColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: projectCyan,
            borderRadius: BorderRadius.circular(
              24,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF207378),
                offset: Offset(1, 2),
                spreadRadius: .3,
                blurRadius: 4.2,
              ),
            ]),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(talepEden),
              Text(talepDetayi),
            ],
          ),
        ),
      ),
    );
  }
}
