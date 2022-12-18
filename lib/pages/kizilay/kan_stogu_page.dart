import 'package:flutter/material.dart';

class KanStokPage extends StatefulWidget {
  const KanStokPage({super.key});

  @override
  State<KanStokPage> createState() => _KanStokPageState();
}

class _KanStokPageState extends State<KanStokPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text("kan Stoğu")),
    );
  }
}
