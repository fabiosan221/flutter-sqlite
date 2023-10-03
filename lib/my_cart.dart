import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_sqlite/models.dart';
import 'package:shop_sqlite/notifier.dart';
import 'package:shop_sqlite/shop_database.dart';

class MyCart extends StatelessWidget {
  //Lista de elementos que se almacenan en el carro de compras personal
  //var cartItems = [CartItem(id: 1, name: 'Asus', price: 780000, quantity: 2)];
  //Lista vacia en la cual se van a cargar los elementos que se seleccionen del
  //Shopping
  //var cartItems = [];
  @override
  Widget build(BuildContext context) {
    //Se especificar mediante el widget Consumer que se va a consumir
    //Para este caso es un CartNotifier
    return Consumer<CartNotifier>(
      //El notifier se utiliza para indicar que al widget se debe redibujar
      builder: (context, value, child) {
        //Se utiliza el widget FutureBuilder que permite construir otros widget
        //cuando hay una operación asincrónica de por medio a la cual se debe
        //esperar
        return FutureBuilder(
            future: ShopDatabase.instance.getAllItems(),
            //Funcion que recibe el contexto y un AsyncSnapshot con la lista de
            //CartItem
            builder:
                (BuildContext context, AsyncSnapshot<List<CartItem>> snapshot) {
              //Se verifica si el snapshot tiene datos obtenidos de la base
              //Mientras se ejecuta el Future, no hay datos disponibles. Una vez
              //terminada se obtienen los datos
              if (snapshot.hasData) {
                List<CartItem> cartItems = snapshot.data!;
                return cartItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos seleccionados',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              color: Colors.brown[50],
                              child: _CartItem(cartItems[index]));
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                              height: 10,
                            ),
                        itemCount: cartItems.length);
              } else {
                //En el caso de que no existan datos en el snapshot por alguna razon,
                //por ejemplo, que la base de datos no se haya creado
                //Si la lista de items del carro esta vacia, se muestra un mensaje
                return const Center(
                  child: Text(
                    'No hay productos seleccionados',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }
            });
      },
    );
  }
}

//Metodo que genera las filas de la lista del carro de compras
class _CartItem extends StatelessWidget {
  final CartItem cartItem;

  //Constructor del item del carro
  const _CartItem(this.cartItem);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        //Se envuelven todas las filas de la lista con el widget DefaultTextStyle
        //para configurar los estilos de los textos como tamaño, color, entre
        //otros
        child: DefaultTextStyle.merge(
          //Se establecen los parámetros de configuración del texto
          style: TextStyle(fontSize: 18, color: Colors.orange[900]),
          child: Row(
            children: [
              Image.asset(
                'assets/images/notebook.png',
                width: 100,
              ),
              //Se agrega un widget Expanded para estirar el area donde se coloca
              //el texto, colocandose al final con la propiedad CrossAxisAlignment.end
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(cartItem.name),
                  Text("\$ ${cartItem.price}"),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('${cartItem.quantity} unidades'),
                    //Se agregan 2 botones que permitiran aumentar o disminuir
                    //la cantidad de unidades de un producto
                    ElevatedButton(
                      onPressed: () async {
                        //Al hacer click en el boton se aumenta la cantidad de
                        //productos
                        cartItem.quantity++;
                        //Se realiza el llamado a la base de datos con la operacion
                        //update
                        await ShopDatabase.instance.update(cartItem);
                        //Se notifica el cambio para que el widget se vuelva
                        //a redibujar
                        Provider.of<CartNotifier>(context, listen: false)
                            .shouldRefresh();
                      },
                      child: const Text('+'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.green),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        //Al hacer click en el boton se disminuye la cantidad de
                        //productos
                        cartItem.quantity--;

                        //Se realiza una verificación para cuando el contador
                        //de unidades llegue a cero, eliminar el producto de la
                        //lista
                        if (cartItem.quantity == 0) {
                          await ShopDatabase.instance.delete(cartItem.id);
                        } else {
                          //Se realiza el llamado a la base de datos con la operacion
                          //update
                          await ShopDatabase.instance.update(cartItem);
                        }
                        //Se notifica el cambio para que el widget se vuelva
                        //a redibujar
                        Provider.of<CartNotifier>(context, listen: false)
                            .shouldRefresh();
                      },
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          minimumSize: Size.zero,
                          backgroundColor: Colors.blue),
                    ),
                  ]),
                  Text('Total: \$ ${cartItem.totalPrice}'),
                  //Se agrega un boton para eliminar el producto del carro de
                  //compra
                  ElevatedButton(
                    //Al presionar el boton, se genera la instancia de la base
                    //de datos llamando al metodo que elimina el producto en
                    //base a un ID
                    onPressed: () async {
                      await ShopDatabase.instance.delete(cartItem.id);
                      //Se muestra un mensaje en la parte inferior del dispositivo
                      //para indicar que el producto se ha eliminado del
                      //carro de compra
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Producto eliminado!'),
                        duration: Duration(seconds: 2),
                      ));
                      //Una vez que el elemento se elimina de la base de datos
                      //Se llama al provider para redibujar el widget
                      Provider.of<CartNotifier>(context, listen: false)
                          .shouldRefresh();
                    },
                    child: const Text('Eliminar'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ))
            ],
          ),
        ));
  }
}
