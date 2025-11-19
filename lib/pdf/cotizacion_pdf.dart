import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<pw.Document> generarPDF(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  // Colores Novotrace
  final azulOscuro = PdfColor.fromHex("#003d82");
  final azulElectrico = PdfColor.fromHex("#00a8e8");
  final grisOscuro = PdfColor.fromHex("#37474F");
  final cotizacion = data['cotizacion'] as Map<String, dynamic>;
  final productos = data['productos'] as List<dynamic>;

  // Cargar logo (si existe)
  pw.ImageProvider? logo;
  try {
    final logoBytes = await rootBundle.load('assets/logo_novotrace.png');
    logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
  } catch (e) {
    // Si no hay logo, continuamos sin él
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // HEADER
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo y datos empresa
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Image(logo, width: 150, height: 60)
                else
                  pw.Text(
                    cotizacion['empresa'] ?? 'NOVOTRACE S.A.C.',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: azulOscuro,
                    ),
                  ),
                pw.SizedBox(height: 12),
                _textoPequeno(
                  cotizacion['direccion_empresa'] ?? '',
                  grisOscuro,
                ),
                _textoPequeno(cotizacion['telefono_empresa'] ?? '', grisOscuro),
                _textoPequeno(cotizacion['email_empresa'] ?? '', grisOscuro),
              ],
            ),

            // Título y número
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: azulOscuro,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    'COTIZACIÓN',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  cotizacion['numero_cotizacion'] ?? '',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: grisOscuro,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 30),

        // Línea divisoria
        pw.Container(
          height: 2,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(colors: [azulOscuro, azulElectrico]),
          ),
        ),

        pw.SizedBox(height: 30),

        // INFORMACIÓN CLIENTE Y DETALLES
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Datos del cliente
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _encabezadoSeccion('CLIENTE', azulElectrico),
                  pw.SizedBox(height: 10),
                  _textoNegrita(cotizacion['cliente'] ?? ''),
                  _textoPequeno(
                    'RUC: ${cotizacion['ruc'] ?? 'N/A'}',
                    grisOscuro,
                  ),
                  _textoPequeno(
                    cotizacion['direccion_cliente'] ?? '',
                    grisOscuro,
                  ),
                ],
              ),
            ),

            pw.SizedBox(width: 30),

            // Detalles de la cotización
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _encabezadoSeccion('DETALLES', azulElectrico),
                  pw.SizedBox(height: 10),
                  _filaDetalle('Fecha:', cotizacion['fecha'] ?? ''),
                  _filaDetalle('Moneda:', cotizacion['moneda'] ?? ''),
                  _filaDetalle(
                    'Validez:',
                    '${cotizacion['validez_dias'] ?? ''} días',
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 30),

        // TABLA DE PRODUCTOS
        _encabezadoSeccion('PRODUCTOS / SERVICIOS', azulOscuro),
        pw.SizedBox(height: 15),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: azulOscuro),
              children: [
                _celdaHeader('DESCRIPCIÓN'),
                _celdaHeader('CANT.'),
                _celdaHeader('P. UNITARIO'),
                _celdaHeader('TOTAL'),
              ],
            ),

            // Productos
            ...productos.map(
              (p) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: productos.indexOf(p) % 2 == 0
                      ? PdfColors.white
                      : PdfColors.grey100,
                ),
                children: [
                  _celdaProducto(p['nombre'] ?? ''),
                  _celdaProducto(p['cantidad'].toString(), centrado: true),
                  _celdaProducto(
                    'S/ ${(p['precio_unitario'] as num).toStringAsFixed(2)}',
                    centrado: true,
                  ),
                  _celdaProducto(
                    'S/ ${(p['total'] as num).toStringAsFixed(2)}',
                    centrado: true,
                    negrita: true,
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 30),

        // TOTALES
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 250,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _filaTotal(
                    'Subtotal:',
                    'S/ ${(cotizacion['subtotal'] as num).toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 8),
                  _filaTotal(
                    'IGV (18%):',
                    'S/ ${(cotizacion['igv'] as num).toStringAsFixed(2)}',
                  ),
                  pw.Divider(thickness: 1.5, color: grisOscuro),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: azulOscuro,
                        ),
                      ),
                      pw.Text(
                        'S/ ${(cotizacion['total'] as num).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: azulOscuro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 30),

        // NOTAS COMERCIALES
        if (cotizacion['notas_comerciales'] != null &&
            (cotizacion['notas_comerciales'] as String).isNotEmpty) ...[
          _encabezadoSeccion('NOTAS COMERCIALES', azulOscuro),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              cotizacion['notas_comerciales'] ?? '',
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
            ),
          ),
          pw.SizedBox(height: 20),
        ],

        // MEDIOS DE PAGO
        pw.SizedBox(height: 20),
        _encabezadoSeccion('MEDIOS DE PAGO', azulOscuro),
        pw.SizedBox(height: 15),

        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _textoNegrita('BANCO DE CRÉDITO DEL PERÚ (BCP)'),
                  pw.SizedBox(height: 6),
                  _textoPequeno('Cuenta Soles: 19491893576091', grisOscuro),
                  _textoPequeno('CCI: 002194918935760910', grisOscuro),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _textoNegrita('BBVA PERÚ'),
                  pw.SizedBox(height: 6),
                  _textoPequeno('Cuenta Soles: 001103233602005998', grisOscuro),
                  _textoPequeno('Moneda: Soles', grisOscuro),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 40),

        // FOOTER
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: azulOscuro,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'novotrace.com.pe',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'ventas@novotrace.com.pe',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],

      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: grisOscuro),
        ),
      ),
    ),
  );

  return pdf;
}

// ============ HELPERS ============

pw.Widget _encabezadoSeccion(String texto, PdfColor color) {
  return pw.Text(
    texto,
    style: pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: color,
    ),
  );
}

pw.Widget _textoNegrita(String texto) {
  return pw.Text(
    texto,
    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget _textoPequeno(String texto, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Text(texto, style: pw.TextStyle(fontSize: 9, color: color)),
  );
}

pw.Widget _filaDetalle(String label, String valor) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          valor,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

pw.Widget _celdaHeader(String texto) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      texto,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );
}

pw.Widget _celdaProducto(
  String texto, {
  bool centrado = false,
  bool negrita = false,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      texto,
      textAlign: centrado ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

pw.Widget _filaTotal(String label, String valor) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
      pw.Text(
        valor,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}
