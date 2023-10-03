//Paquete para implementar la libreria sqflite
import 'package:sqflite/sqflite.dart';

//Paquete para implementar la creacion de rutas de manera segura
//independientemente del sistema operativo
import 'package:path/path.dart';

import 'package:shop_sqlite/models.dart';

class ShopDatabase {
  //Para acceder a la base datos de cualquier parte de la aplicacion
  //se utiliza el patron singleton. Se mantiene una instancia estatica de la
  //base de datos
  static final ShopDatabase instance = ShopDatabase._init();

  //Base de datos real
  static Database? _database;

  ShopDatabase._init();

  //Variable para almacenar el nombre de la tabla cart_items
  final String tableCartItems = 'cart_items';

  //Llamada a la base de datos
  Future<Database> get database async {
    //Se verifica que la misma este creada
    if (_database != null) return _database!;
    //En el caso de que no este creada la base de datos, se genera la misma
    _database = await _initDB('shop.db');
    return _database!;
  }

  //Al metodo _initDB se le pasa el nombre de la base de datos para generarla
  //En este caso, sera shop.db. Este nombre indica que se va a generar un archivo
  //de manera local o fisica en el dispositivo, el cual va a contener la
  //base de datos sqlite
  Future<Database> _initDB(String filePath) async {
    //El metodo getDatabasesPath indica la ubicacion por defecto
    //donde se almacena el archivo la base de datos.
    //En android es data/data/<package_name>/databases
    final dbPath = await getDatabasesPath();

    //Se puede generar la ruta utilizando la concatenacion de la barra de
    //direcciones, pero tiene el inconveniente de que varia con el sistema
    //operativo de la pc donde se genera la aplicacion
    //final path = dbPath + '/' + filePath;

    //Una opcion mas segura es generar la ruta completa o path con el metodo
    //join del paquete path.dart
    final path = join(dbPath, filePath);

    //Una vez que se posee la ruta completa, se llama al metodo openDatabase
    //donde se le indica la ruta y una accion a realizar por primera vez dentro
    //de onCreate, por ejemplo, la creacion de la tablas
    //Se utilizar el asincronismo mediante await para esperar a que se complete
    //la creación de tablas
    //Se indica la version de la base de datos. Cada vez que se modifica
    //la estructura de una tabla, se debe especificar una nueva version
    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  //Creación de la base de datos
  Future _onCreateDB(Database db, int version) async {
    //Si es la primera vez que se abre la base de datos, crea una tabla
    //Al método db.execute se le pasa como parámetro una declaración SQL para
    //generar una tabla, en este caso, la tabla del carro de compras
    //Se utiliza triple comillas para poder generar la consultas con saltos de
    //lineas permitiendo una mejor visualizacion
    await db.execute('''
      CREATE TABLE $tableCartItems(
        id INTEGER PRIMARY KEY,
        name TEXT,
        price INTEGER,
        quantity INTEGER
      )
    ''');
  }

  //Método para insertar registros en la base de datos
  Future<void> insert(CartItem item) async {
    //Referencia a la base de datos
    final db = await instance.database;
    //Una vez que se obtiene la base de datos, se realiza un insert
    //Se pasa como parametro el nombre de la tabla y un mapa con los valores a
    //insertar
    await db.insert(tableCartItems, item.toMap(),
        //conflictAlgorithm permite realizar acciones cuando se produce un error
        //Para el caso del ejemplo desarrollado, cuando se desea agregar un item
        //dos veces al carro de comprar, surge un conflicto de clave primaria
        //repetida en la base de datos. Ya que 2 registros tienen la misma clave
        //A partir de ello, es que se reemplaza el registro cada vez que se
        //realiza esta acción
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //Método que devuelve una lista con items para el carro de compras
  Future<List<CartItem>> getAllItems() async {
    //Se obtiene la instancia de la base de datos
    final db = await instance.database;
    //Se realiza una consulta de todos los datos
    final List<Map<String, dynamic>> maps = await db.query(tableCartItems);
    //Luego se convierte cada unos de los mapas que forman la lista de la
    //consulta en un CartItem
    //Se utiliza el metodo List.generate para crear una lista de CartItems a
    //partir de los registros almacenados en la base de datos
    return List.generate(maps.length, (i) {
      return CartItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        price: maps[i]['price'],
        quantity: maps[i]['quantity'],
      );
    });
  }

  //Método para eliminar elementos de la base de datos
  Future<int> delete(int id) async {
    //Generación de la instancia de la base de datos
    final db = await instance.database;
    //Al metodo delete, se le pasa como parametro el nombre de la tabla
    //junto con la sentencia sql con las condiciones de las tuplas a eliminar
    return await db.delete(tableCartItems, where: 'id = ?', whereArgs: [id]);
  }

  //Metodo para actualizar los datos de unidades de un producto en el carro de compras
  Future<int> update(CartItem item) async {
    //Generación de la instancia de la base de datos
    final db = await instance.database;
    //Se realiza la operacion para actualizar una tupla
    return await db.update(tableCartItems, item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }
}
