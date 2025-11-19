import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../tema.dart';
import '../widgets/input_field.dart';
import '../database/conexion.dart';
import 'historial_cotizaciones.dart';
import 'ver_pdf.dart';

class NuevaCotizacion extends StatefulWidget {
  const NuevaCotizacion({super.key});

  @override
  State<NuevaCotizacion> createState() => _NuevaCotizacionState();
}

class _NuevaCotizacionState extends State<NuevaCotizacion> {
  // Controllers
  final empresaCtrl = TextEditingController(text: "NOVOTRACE S.A.C.");
  final direccionEmpresaCtrl = TextEditingController(
    text:
        "Av. Cesar Vallejo Sector 2 Grupo 5 Manza H Lote 11, Villa El Salvador",
  );
  final telefonoCtrl = TextEditingController(text: "+51 987 654 321");
  final emailCtrl = TextEditingController(text: "ventas@novotrace.com.pe");

  final numeroCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final monedaCtrl = TextEditingController(text: "Soles (S/)");
  final validezCtrl = TextEditingController(text: "30");

  final clienteCtrl = TextEditingController();
  final rucCtrl = TextEditingController();
  final direccionClienteCtrl = TextEditingController();
  final notasCtrl = TextEditingController(
    text:
        "• Precios incluyen IGV\n• Tiempo de entrega: 5-7 días hábiles\n• Garantía: 12 meses",
  );

  // Producto temporal
  final productoCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  List<Map<String, dynamic>> productos = [];
  bool mostrarVista = false;

  @override
  void initState() {
    super.initState();
    _generarNumeroCotizacion();
    _establecerFechaActual();
  }

  void _generarNumeroCotizacion() {
    final ahora = DateTime.now();
    numeroCtrl.text =
        "COT-${ahora.year}-${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}-${ahora.millisecondsSinceEpoch.toString().substring(8)}";
  }

  void _establecerFechaActual() {
    fechaCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  double get subtotal {
    return productos.fold(0, (sum, p) => sum + p['total']);
  }

  double get igv => subtotal * 0.18;
  double get total => subtotal + igv;

  void agregarProducto() {
    if (productoCtrl.text.isEmpty ||
        cantidadCtrl.text.isEmpty ||
        precioCtrl.text.isEmpty) {
      _mostrarSnackbar(
        "⚠️ Completa todos los campos del producto",
        Colors.orange,
      );
      return;
    }

    final cant = int.tryParse(cantidadCtrl.text) ?? 0;
    final precio = double.tryParse(precioCtrl.text) ?? 0.0;

    if (cant <= 0 || precio <= 0) {
      _mostrarSnackbar(
        "⚠️ Cantidad y precio deben ser mayores a 0",
        Colors.orange,
      );
      return;
    }

    setState(() {
      productos.add({
        'nombre': productoCtrl.text,
        'cantidad': cant,
        'precio_unitario': precio,
        'total': cant * precio,
      });
    });

    productoCtrl.clear();
    cantidadCtrl.clear();
    precioCtrl.clear();

    _mostrarSnackbar("✓ Producto agregado", TemaApp.verdeExito);
  }

  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
    _mostrarSnackbar("Producto eliminado", TemaApp.grisOscuro);
  }

  void limpiarProductos() {
    setState(() {
      productos.clear();
      productoCtrl.clear();
      cantidadCtrl.clear();
      precioCtrl.clear();
    });
  }

  void generarVista() {
    if (clienteCtrl.text.isEmpty) {
      _mostrarSnackbar("⚠️ Ingresa el nombre del cliente", Colors.orange);
      return;
    }

    if (productos.isEmpty) {
      _mostrarSnackbar("⚠️ Agrega al menos un producto", Colors.orange);
      return;
    }

    setState(() {
      mostrarVista = true;
    });

    _mostrarSnackbar("✓ Vista previa generada", TemaApp.verdeExito);
  }

  Future<void> guardarYGenerarPDF() async {
    if (clienteCtrl.text.isEmpty || productos.isEmpty) {
      _mostrarSnackbar(
        "⚠️ Completa los datos y agrega productos",
        Colors.orange,
      );
      return;
    }

    try {
      final cotizacion = {
        'numero_cotizacion': numeroCtrl.text,
        'fecha': fechaCtrl.text,
        'cliente': clienteCtrl.text,
        'ruc': rucCtrl.text,
        'direccion_cliente': direccionClienteCtrl.text,
        'empresa': empresaCtrl.text,
        'direccion_empresa': direccionEmpresaCtrl.text,
        'telefono_empresa': telefonoCtrl.text,
        'email_empresa': emailCtrl.text,
        'moneda': monedaCtrl.text,
        'validez_dias': validezCtrl.text,
        'notas_comerciales': notasCtrl.text,
        'subtotal': subtotal,
        'igv': igv,
        'total': total,
        'fecha_creacion': DateTime.now().toIso8601String(),
      };

      final id = await ConexionDB.guardarCotizacion(cotizacion, productos);

      _mostrarSnackbar(
        "✓ Cotización guardada exitosamente",
        TemaApp.verdeExito,
      );

      // Navegar al PDF
      final datosCompletos = await ConexionDB.obtenerCotizacionCompleta(id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerPDF(datosCompletos)),
      );
    } catch (e) {
      _mostrarSnackbar("❌ Error al guardar: $e", TemaApp.rojoAlerta);
    }
  }

  void limpiarTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Limpiar todo?"),
        content: const Text("Se perderán todos los datos ingresados."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _generarNumeroCotizacion();
                _establecerFechaActual();
                clienteCtrl.clear();
                rucCtrl.clear();
                direccionClienteCtrl.clear();
                productos.clear();
                productoCtrl.clear();
                cantidadCtrl.clear();
                precioCtrl.clear();
                mostrarVista = false;
              });
              _mostrarSnackbar("Formulario limpiado", TemaApp.grisOscuro);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaApp.rojoAlerta,
            ),
            child: const Text("Limpiar"),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackbar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset("assets/logo_novotrace.png", height: 36),
            const SizedBox(width: 12),
            const Text("Nueva Cotización"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistorialCotizaciones()),
              );
            },
            tooltip: "Ver historial",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // PANEL IZQUIERDO - FORMULARIO
          Container(
            width: isDesktop ? 480 : double.infinity,
            color: TemaApp.blanco,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _seccionEncabezado(),
                const SizedBox(height: 24),
                _seccionEmpresa(),
                const SizedBox(height: 24),
                _seccionCotizacion(),
                const SizedBox(height: 24),
                _seccionCliente(),
                const SizedBox(height: 24),
                _seccionProductos(),
                const SizedBox(height: 24),
                _seccionResumen(),
                const SizedBox(height: 24),
                _seccionNotas(),
                const SizedBox(height: 32),
                _botonesAccion(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // PANEL DERECHO - VISTA PREVIA
          if (isDesktop)
            Expanded(
              child: Container(
                color: TemaApp.grisClaro,
                padding: const EdgeInsets.all(32),
                child: mostrarVista ? _vistaPrevia() : _placeholderVista(),
              ),
            ),
        ],
      ),
    );
  }

  // ============ SECCIONES DEL FORMULARIO ============

  Widget _seccionEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Crear Cotización",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          "Complete los datos para generar una cotización profesional",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Container(height: 3, color: TemaApp.azulElectrico),
      ],
    );
  }

  Widget _seccionEmpresa() {
    return _seccionConTitulo("Datos de la Empresa", Icons.business_rounded, [
      InputField(label: "Empresa", controller: empresaCtrl),
      InputField(label: "Dirección", controller: direccionEmpresaCtrl),
      Row(
        children: [
          Expanded(
            child: InputField(label: "Teléfono", controller: telefonoCtrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputField(label: "Email", controller: emailCtrl),
          ),
        ],
      ),
    ]);
  }

  Widget _seccionCotizacion() {
    return _seccionConTitulo(
      "Datos de la Cotización",
      Icons.description_rounded,
      [
        InputField(
          label: "N° Cotización",
          controller: numeroCtrl,
          readOnly: true,
        ),
        Row(
          children: [
            Expanded(
              child: InputField(label: "Fecha", controller: fechaCtrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputField(label: "Moneda", controller: monedaCtrl),
            ),
          ],
        ),
        InputField(label: "Validez (días)", controller: validezCtrl),
      ],
    );
  }

  Widget _seccionCliente() {
    return _seccionConTitulo("Datos del Cliente", Icons.person_rounded, [
      InputField(label: "Cliente / Razón Social", controller: clienteCtrl),
      Row(
        children: [
          Expanded(
            child: InputField(label: "RUC / DNI", controller: rucCtrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputField(
              label: "Dirección",
              controller: direccionClienteCtrl,
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _seccionProductos() {
    return _seccionConTitulo(
      "Productos / Servicios",
      Icons.inventory_2_rounded,
      [
        InputField(label: "Producto/Servicio", controller: productoCtrl),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: InputField(label: "Cantidad", controller: cantidadCtrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: InputField(
                label: "Precio Unitario (S/)",
                controller: precioCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: agregarProducto,
                icon: const Icon(Icons.add_rounded),
                label: const Text("Agregar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TemaApp.verdeExito,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: limpiarProductos,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text("Limpiar"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _tablaProductos(),
      ],
    );
  }

  Widget _seccionResumen() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TemaApp.azulOscuro, TemaApp.azulElectrico],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TemaApp.azulElectrico.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _filaResumen("Subtotal:", subtotal),
          const SizedBox(height: 8),
          _filaResumen("IGV (18%):", igv),
          const Divider(color: Colors.white38, thickness: 1, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "S/ ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(String label, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        Text(
          "S/ ${valor.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _seccionNotas() {
    return _seccionConTitulo("Notas Comerciales", Icons.note_rounded, [
      InputField(
        label: "Condiciones, garantías, tiempo de entrega...",
        controller: notasCtrl,
        maxLines: 5,
      ),
    ]);
  }

  Widget _seccionConTitulo(
    String titulo,
    IconData icono,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: TemaApp.azulOscuro, size: 22),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TemaApp.azulOscuro,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _tablaProductos() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: TemaApp.azulOscuro,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderTabla("PRODUCTO")),
                Expanded(flex: 1, child: _HeaderTabla("CANT.")),
                Expanded(flex: 2, child: _HeaderTabla("P. UNIT.")),
                Expanded(flex: 2, child: _HeaderTabla("TOTAL")),
                SizedBox(width: 40),
              ],
            ),
          ),
          productos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No hay productos agregados",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              p['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              p['cantidad'].toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "S/ ${p['precio_unitario'].toStringAsFixed(2)}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "S/ ${p['total'].toStringAsFixed(2)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: TemaApp.rojoAlerta,
                              size: 20,
                            ),
                            onPressed: () => eliminarProducto(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _botonesAccion() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: generarVista,
            icon: const Icon(Icons.visibility_rounded),
            label: const Text("Generar Vista Previa"),
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaApp.azulElectrico,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: guardarYGenerarPDF,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text("Guardar y Generar PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaApp.verdeExito,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: limpiarTodo,
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text("Limpiar Todo"),
            style: OutlinedButton.styleFrom(
              foregroundColor: TemaApp.rojoAlerta,
              side: const BorderSide(color: TemaApp.rojoAlerta),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderVista() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.preview_rounded, size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            "Vista Previa",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Completa los datos y haz clic en\n'Generar Vista Previa'",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _vistaPrevia() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/logo_novotrace.png", height: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "COTIZACIÓN",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TemaApp.azulOscuro,
                      ),
                    ),
                    Text(
                      numeroCtrl.text,
                      style: TextStyle(fontSize: 14, color: TemaApp.grisOscuro),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 40, thickness: 2),

            // Información empresa y cliente
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _bloqueInfo("DE:", [
                    empresaCtrl.text,
                    direccionEmpresaCtrl.text,
                    telefonoCtrl.text,
                    emailCtrl.text,
                  ]),
                ),
                Expanded(
                  child: _bloqueInfo("PARA:", [
                    clienteCtrl.text,
                    "RUC: ${rucCtrl.text}",
                    direccionClienteCtrl.text,
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Detalles cotización
            Row(
              children: [
                _detalleCotizacion("Fecha", fechaCtrl.text),
                const SizedBox(width: 24),
                _detalleCotizacion("Moneda", monedaCtrl.text),
                const SizedBox(width: 24),
                _detalleCotizacion("Validez", "${validezCtrl.text} días"),
              ],
            ),

            const SizedBox(height: 30),

            // Tabla productos
            _tablaProductos(),

            const SizedBox(height: 30),

            // Totales
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TemaApp.grisClaro,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _filaTotalVista("Subtotal:", subtotal),
                    const SizedBox(height: 8),
                    _filaTotalVista("IGV (18%):", igv),
                    const Divider(height: 24),
                    _filaTotalVista("TOTAL:", total, esTotal: true),
                  ],
                ),
              ),
            ),

            if (notasCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text(
                "NOTAS COMERCIALES",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TemaApp.azulOscuro,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TemaApp.grisClaro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notasCtrl.text,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bloqueInfo(String titulo, List<String> lineas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: TemaApp.azulElectrico,
          ),
        ),
        const SizedBox(height: 8),
        ...lineas.map(
          (linea) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(linea, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _detalleCotizacion(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: TemaApp.grisOscuro,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _filaTotalVista(String label, double valor, {bool esTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: esTotal ? 16 : 14,
            fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "S/ ${valor.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: esTotal ? 20 : 14,
            fontWeight: esTotal ? FontWeight.bold : FontWeight.w600,
            color: esTotal ? TemaApp.azulOscuro : null,
          ),
        ),
      ],
    );
  }
}

class _HeaderTabla extends StatelessWidget {
  final String texto;
  const _HeaderTabla(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
