class Cotizacion {
  int? id;
  String cliente;
  double subtotal;
  double igv;
  double total;
  String fecha;

  Cotizacion({
    this.id,
    required this.cliente,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "cliente": cliente,
    "subtotal": subtotal,
    "igv": igv,
    "total": total,
    "fecha": fecha,
  };
}
