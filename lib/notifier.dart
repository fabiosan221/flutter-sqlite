import 'package:flutter/material.dart';

class CartNotifier extends ChangeNotifier {
  void shouldRefresh() {
    //Se llama al metodo que esta escuchando el llamado del objeto que luego
    //debe redibujarse
    notifyListeners();
  }
}
