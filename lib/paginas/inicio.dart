import 'package:flutter/material.dart';
import '../database/conexion.dart';
import 'nueva_cotizacion.dart';
import 'ver_pdf.dart';
import '../tema.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  List cotizaciones = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future cargar() async {
    final db = await ConexionDB.db;
    final data = await db.query("cotizaciones", orderBy: "id DESC");
    setState(() => cotizaciones = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: TemaApp.azulOscuro, // ✅ CAMBIO
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/logo_novotrace.png", height: 38),
            const SizedBox(width: 12),
            const Text(
              "Cotizaciones",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TemaApp.azulElectrico, // ✅ CAMBIO
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NuevaCotizacion()),
          );
          cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: cotizaciones.isEmpty
          ? const Center(
              child: Text(
                "Sin cotizaciones aún",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: cotizaciones.length,
              itemBuilder: (_, i) {
                final c = cotizaciones[i];
                return Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    title: Text(
                      c["cliente"],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      "Total: S/ ${c["total"].toStringAsFixed(2)}\nFecha: ${c["fecha"]}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf, size: 30),
                      color: TemaApp.azulOscuro, // ✅ CAMBIO
                      onPressed: () async {
                        // ✅ Necesitamos cargar datos completos
                        final datos =
                            await ConexionDB.obtenerCotizacionCompleta(c['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VerPDF(datos)),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
