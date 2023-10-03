class Product {
  final int id;
  final String name;
  final String description;
  final int price;

  Product(this.id, this.name, this.description, this.price);
}

class CartItem {
  final int id;
  final String name;
  final int price;
  int quantity;

  //Se usa parametro con nombres y se le agrega la propiedad de requeridos
  CartItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity});

  //Calcula el precio total
  get totalPrice {
    return quantity * price;
  }

  //Metodo para generar un mapa que sirve como estructura para las insercciones
  //en la base de datos
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }
}
