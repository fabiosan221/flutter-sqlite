import 'package:flutter/material.dart';
import 'package:shop_sqlite/models.dart';
import 'package:shop_sqlite/shop_database.dart';

class ProductsList extends StatelessWidget {
  //Se genera una lista estática de productos
  var products = [
    Product(1, 'Asus', 'Intel I7, 16Gb Ram, SSD 512GB', 780000),
    Product(2, 'HP', 'Intel I5, 8Gb Ram, SSD 256GB', 580000),
    Product(3, 'Dell', 'Intel I9, 32Gb Ram, SSD 512GB', 980000)
  ];

  @override
  Widget build(BuildContext context) {
    //Se genera una lista de items. Se usa el constructor separated para agregar
    //una linea de separacion entre los diferentes elementos
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          //Se captura la accion del ontap sobre un producto para poder
          //agregarlo al carro de compras mediante el widget GestureDetector
          //que detecta los gestos que se hacen sobre el dispositivo
          return GestureDetector(
            child: Container(
                color: Colors.amber[50], child: ProductItem(products[index])),
            onTap: () async {
              //Llamamos al metodo que va a permitir crear el registro en la
              //base de datos
              await addToCart(products[index]);
              //Se muestra un mensaje en la parte inferior del dispositivo
              //para indicar que el producto se ha agregado al carro de compra
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Producto agregado!'),
                duration: Duration(seconds: 2),
              ));
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            //Divisor de items
            const Divider(
              height: 5,
            ),
        itemCount: products.length);
  }
}

//Método para agregar el producto seleccionado al carro de compras
Future<void> addToCart(Product product) async {
  //Se genera un item para insertar
  final item = CartItem(
      id: product.id, name: product.name, price: product.price, quantity: 1);
  await ShopDatabase.instance.insert(item);
}

//Este método es la representación de un producto
class ProductItem extends StatelessWidget {
  final Product product;

  //Constructor del producto
  const ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/notebook.png',
            width: 100,
          ),
          //Padding para separar la imagen del texto
          const Padding(padding: EdgeInsets.only(right: 3, left: 3)),
          Column(
            //Se alinean los elementos de las lista de productos
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name),
              Text(product.description),
              Text("\$ ${product.price}"),
            ],
          )
        ],
      ),
    );
  }
}
