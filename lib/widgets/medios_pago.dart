import 'package:flutter/material.dart';

class MediosPago extends StatelessWidget {
  const MediosPago({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "MEDIOS DE PAGO",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Image.asset("assets/BCP.png", height: 50),
        const Text("Cuenta Soles: 19491893576091"),
        const Text("CCI: 002194918935760910"),
        const SizedBox(height: 15),
        Image.asset("assets/BBVA.png", height: 50),
        const Text("Cuenta Soles: 001103233602005998"),
        const Text("Moneda: Soles"),
      ],
    );
  }
}
