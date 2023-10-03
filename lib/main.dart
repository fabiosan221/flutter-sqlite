import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_sqlite/notifier.dart';
import 'package:shop_sqlite/products_list.dart';
import 'package:shop_sqlite/my_cart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Sqlite',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      //Se crea el Notifier
      home: ChangeNotifierProvider(
          //Se indica el tipo de Notifier a utilizar
          create: (contex) => CartNotifier(),
          child: const MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Variable que es parte del estado que cambia con la selección del botón
  //de la barra de navegación
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Sqlite'),
      ),
      //Se agrega el widget de la lista de productos
      //El _selectedIndex va a permitir que se pueda navegar entre las
      //2 pantallas, es decir, entre Shopping y MyCart
      body: _selectedIndex == 0 ? ProductsList() : MyCart(),
      //Barra de navegación inferior con 2 botones
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'My Cart'),
        ],
        //Indica el ítem seleccionado en el BottomNavigationBar
        currentIndex: _selectedIndex,
        //Color del ítem seleccionado
        selectedItemColor: Colors.red[900],
        //Función que se ejecuta cuando se presiona sobre el botón de la barra
        onTap: (index) {
          //Al presionar un botón de la barra de navegación se cambia el índice
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
