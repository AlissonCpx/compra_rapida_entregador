import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/corrida.dart';
import 'package:compra_rapida_entregador/model/order.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/model/user.dart';
import 'package:compra_rapida_entregador/util/util.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class listaInfo extends StatefulWidget {
  @override
  _listaInfoState createState() => _listaInfoState();

  OrderPed order;
  Shopper shop;

  listaInfo(this.order, this.shop);
}

class _listaInfoState extends State<listaInfo> {
  List itensPed;
  User user = User();

  @override
  void initState() {
    super.initState();
    itensPed = widget.order.itens;
    pesqUser();
  }

  void pesqUser() async {
    User u = await Util.pesquisaUser(widget.order.userClId.idUser
    );
    setState(() {
      user = u;
    });
  }

  void aceitaPedido() async {

    Shopper shopper = await Util.pesquisaShopper(widget.shop.idUser);


    Firestore db = Firestore.instance;
    db.collection("pedidos")
        .document( widget.order.idPedido )
        .updateData({
      "entregadorClId" : shopper.toMap()
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Corrida(widget.order.idPedido),
        ));
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido"),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 10, 10),
                width: 400,
                height: 450,
                child: Card(
                    elevation: 10,
                    borderOnForeground: true,
                    child: Column(
                      children: <Widget>[
                        AppBar(
                          backgroundColor: Colors.deepPurple,
                          title: Text("Itens"),
                          automaticallyImplyLeading: false,
                          actions: <Widget>[],
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: widget.order.itens.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text("${index + 1}."),
                                  title: Text(
                                    itensPed[index]["Item"],
                                    maxLines: 1,
                                  ),
                                  subtitle: Text(
                                    itensPed[index]["comment"],
                                    maxLines: 1,
                                  ),
                                );
                              }),
                        ),
                        Divider(
                          color: Colors.deepPurple,
                        ),
                        Text("Quantidade de itens: ${itensPed.length}")
                      ],
                    )),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text("Super Mercado: ${widget.order.nomeMarket}"),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text(
                    "Endereço: ${widget.order.ruaDest}, ${widget.order.numDest}"),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                    "Data: ${formatDate(DateTime.fromMicrosecondsSinceEpoch(widget.order.dataHoraPed.microsecondsSinceEpoch), [
                      dd,
                      '/',
                      mm,
                      '/',
                      yyyy
                    ])}"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Comprador: ${user.nome != null ? user.nome : ""}"),
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text("Valor Entrega: ${30.00}"),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                  width: 300,
                  height: 30,
                  child: PhysicalModel(
                    color: Colors.transparent,
                    shadowColor: Colors.black,
                    elevation: 8.0,
                    child: RaisedButton(
                      child: Text(
                        'Fazer Entrega',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      textColor: Colors.white,
                      color: Colors.greenAccent,
                      onPressed: () {
                        if (true) {
                          aceitaPedido();


                        }
                      },
                    ),
                  )),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
