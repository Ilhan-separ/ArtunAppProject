import 'package:artun_flutter_project/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TalepTile extends StatelessWidget {
  final String talepEden;
  final String kanGrubu;
  final String unite;
  final String durum;
  final String talepSaati;

  TalepTile({
    super.key,
    required this.talepEden,
    required this.kanGrubu,
    required this.unite,
    required this.durum,
    required this.talepSaati,
  });

  String data = "";

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                durum,
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: mediaSize.width * .02,
                    color: projectRed),
              ),
              SizedBox(
                height: mediaSize.height * .006,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    talepEden,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: mediaSize.width * .043,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                  SvgPicture.asset(
                    "assets/ic_talep_$durum.svg",
                    colorFilter: ColorFilter.mode(projectRed, BlendMode.srcIn),
                    height: mediaSize.width * .056,
                  ),
                ],
              ),
              Divider(
                color: projectRed,
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    _myKanGrubuUniteRow("Kan Grubu", kanGrubu, context),
                    _myKanGrubuUniteRow("Ünite", unite, context),
                  ],
                ),
              ),
              Divider(
                color: projectRed,
                height: 6,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Oluşturulma Saati : ",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: mediaSize.width * .03),
                    ),
                    Text(
                      talepSaati,
                      style: GoogleFonts.roboto(
                          color: projectRed,
                          fontWeight: FontWeight.bold,
                          fontSize: mediaSize.width * .03),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _myKanGrubuUniteRow(String subTitle, String value, contex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$subTitle : ",
          style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(contex).size.width * .042),
        ),
        Text(
          "$value",
          style: GoogleFonts.roboto(
              color: projectRed,
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(contex).size.width * .042),
        ),
      ],
    );
  }
}
