import 'package:flutter/material.dart';
import '../database/conexion.dart';
import '../tema.dart';
import 'ver_pdf.dart';

class HistorialCotizaciones extends StatefulWidget {
  const HistorialCotizaciones({super.key});

  @override
  State<HistorialCotizaciones> createState() => _HistorialCotizacionesState();
}

class _HistorialCotizacionesState extends State<HistorialCotizaciones> {
  List<Map<String, dynamic>> cotizaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);
    try {
      final data = await ConexionDB.listarCotizaciones();
      setState(() {
        cotizaciones = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar: $e")));
    }
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar cotización?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaApp.rojoAlerta,
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ConexionDB.eliminarCotizacion(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Cotización eliminada"),
          backgroundColor: TemaApp.grisOscuro,
        ),
      );
      cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/logo_novotrace.png", height: 36),
            const SizedBox(width: 12),
            const Text("Historial de Cotizaciones"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: cargar,
            tooltip: "Actualizar",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : cotizaciones.isEmpty
          ? _vistaVacia()
          : _listaCotizaciones(),
    );
  }

  Widget _vistaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            "No hay cotizaciones guardadas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Las cotizaciones que crees aparecerán aquí",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _listaCotizaciones() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cotizaciones.length,
      itemBuilder: (context, index) {
        final cot = cotizaciones[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final datos = await ConexionDB.obtenerCotizacionCompleta(
                cot['id'],
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VerPDF(datos)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [TemaApp.azulOscuro, TemaApp.azulElectrico],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cot['cliente'] ?? 'Sin cliente',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: TemaApp.azulOscuro,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cot['fecha'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cot['numero_cotizacion'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: TemaApp.verdeExito.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "S/ ${(cot['total'] as num).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TemaApp.verdeExito,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        color: TemaApp.azulElectrico,
                        iconSize: 28,
                        onPressed: () async {
                          final datos =
                              await ConexionDB.obtenerCotizacionCompleta(
                                cot['id'],
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VerPDF(datos)),
                          );
                        },
                        tooltip: "Ver PDF",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: TemaApp.rojoAlerta,
                        iconSize: 24,
                        onPressed: () => eliminar(cot['id']),
                        tooltip: "Eliminar",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
