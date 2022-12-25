import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KanStokPage extends StatefulWidget {
  const KanStokPage({super.key});

  @override
  State<KanStokPage> createState() => _KanStokPageState();
}

class _KanStokPageState extends State<KanStokPage> {
  List<String> bloodList = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: bloodList.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 12,
          thickness: 2,
        );
      },
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            bloodList[index],
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 42,
                color: Color(0xFFF48634),
              ),
            ),
          ),
          trailing: Text("24", style: TextStyle(fontSize: 12)),
        );
      },
    );
  }
}
