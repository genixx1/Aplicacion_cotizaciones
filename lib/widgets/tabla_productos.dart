import 'package:flutter/material.dart';
import '../tema.dart';

class TablaProductos extends StatelessWidget {
  const TablaProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 45,
            decoration: const BoxDecoration(
              color: TemaApp.azulOscuro, // ✅ CAMBIO
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                _header("PRODUCTOS"),
                _header("CANTIDAD"),
                _header("PRECIO UNIT."),
                _header("PRECIO TOTAL"),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "No hay items agregados",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _header extends StatelessWidget {
  final String text;
  const _header(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
