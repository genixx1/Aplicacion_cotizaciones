import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ConexionDB {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), "novotrace_cotizaciones.db");
    _db = await openDatabase(
      ruta,
      version: 2,
      onCreate: (db, version) async {
        // Tabla principal de cotizaciones
        await db.execute("""
          CREATE TABLE cotizaciones(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            numero_cotizacion TEXT,
            fecha TEXT,
            cliente TEXT,
            ruc TEXT,
            direccion_cliente TEXT,
            empresa TEXT,
            direccion_empresa TEXT,
            telefono_empresa TEXT,
            email_empresa TEXT,
            moneda TEXT,
            validez_dias TEXT,
            notas_comerciales TEXT,
            subtotal REAL,
            igv REAL,
            total REAL,
            fecha_creacion TEXT
          )
        """);

        // Tabla de productos por cotización
        await db.execute("""
          CREATE TABLE productos_cotizacion(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cotizacion_id INTEGER,
            nombre TEXT,
            cantidad INTEGER,
            precio_unitario REAL,
            precio_total REAL,
            FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones (id)
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Actualización de base de datos si es necesario
          await db.execute("""
            CREATE TABLE IF NOT EXISTS productos_cotizacion(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cotizacion_id INTEGER,
              nombre TEXT,
              cantidad INTEGER,
              precio_unitario REAL,
              precio_total REAL,
              FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones (id)
            )
          """);
        }
      },
    );

    return _db!;
  }

  // Guardar cotización completa
  static Future<int> guardarCotizacion(
    Map<String, dynamic> cotizacion,
    List<Map<String, dynamic>> productos,
  ) async {
    final database = await db;

    // Insertar cotización
    final cotizacionId = await database.insert('cotizaciones', cotizacion);

    // Insertar productos asociados
    for (var producto in productos) {
      producto['cotizacion_id'] = cotizacionId;
      await database.insert('productos_cotizacion', producto);
    }

    return cotizacionId;
  }

  // Obtener cotización completa con productos
  static Future<Map<String, dynamic>> obtenerCotizacionCompleta(int id) async {
    final database = await db;

    final cotizacion = await database.query(
      'cotizaciones',
      where: 'id = ?',
      whereArgs: [id],
    );

    final productos = await database.query(
      'productos_cotizacion',
      where: 'cotizacion_id = ?',
      whereArgs: [id],
    );

    return {'cotizacion': cotizacion.first, 'productos': productos};
  }

  // Listar todas las cotizaciones
  static Future<List<Map<String, dynamic>>> listarCotizaciones() async {
    final database = await db;
    return await database.query('cotizaciones', orderBy: 'id DESC');
  }

  // Eliminar cotización
  static Future<void> eliminarCotizacion(int id) async {
    final database = await db;
    await database.delete(
      'productos_cotizacion',
      where: 'cotizacion_id = ?',
      whereArgs: [id],
    );
    await database.delete('cotizaciones', where: 'id = ?', whereArgs: [id]);
  }
}
