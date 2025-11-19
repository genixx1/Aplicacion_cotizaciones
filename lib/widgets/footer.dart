import 'package:flutter/material.dart';
import '../tema.dart';

class FooterCotizacion extends StatelessWidget {
  const FooterCotizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaApp.azulOscuro, // ✅ CAMBIO
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          Text("novotrace.com.pe", style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          Text(
            "ventas@novotrace.com.pe",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
