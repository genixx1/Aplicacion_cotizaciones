import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../pdf/cotizacion_pdf.dart';
import '../tema.dart';

class VerPDF extends StatelessWidget {
  final Map<String, dynamic> data;
  const VerPDF(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/logo_novotrace.png", height: 32),
            const SizedBox(width: 12),
            const Text("Vista PDF"),
          ],
        ),
        backgroundColor: TemaApp.azulOscuro,
      ),
      body: PdfPreview(
        build: (format) async {
          final pdf = await generarPDF(data);
          return pdf.save();
        },
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName:
            'Cotizacion_${data['cotizacion']['numero_cotizacion'] ?? 'documento'}.pdf',
        loadingWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: TemaApp.azulElectrico),
              const SizedBox(height: 20),
              Text(
                "Generando PDF...",
                style: TextStyle(
                  fontSize: 16,
                  color: TemaApp.grisOscuro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
