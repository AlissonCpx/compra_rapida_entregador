import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/model/order.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/model/user.dart';
import 'package:compra_rapida_entregador/util/util.dart';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

import 'listaInfo.dart';

class Home extends StatefulWidget {
  Shopper shopper = Shopper();

  Home(this.shopper);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<OrderPed> pedidos = [];
  OrderPed ordersInfos = new OrderPed();
  bool loadingOrder = false;
  bool loadingListas = false;
  bool possuiOrder = false;
  bool possuiLista = false;

  Widget trocaFoto() {
    if (widget.shopper.foto != null) {
      return Container(
          margin: EdgeInsets.zero,
          height: 140,
          width: 140,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.shopper.foto),
          ));
    } else {
      return Container(
          margin: EdgeInsets.zero,
          height: 130,
          width: double.infinity,
          child: CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.person,
              color: Colors.black,
              size: 100,
            ),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    _trazListas();
  }

  _trazListas() async {
    setState(() {
      pedidos = [];
      loadingListas = true;
    });
    Firestore db = Firestore.instance;

    List<DocumentSnapshot> documentList;
    documentList = (await db
            .collection("pedidos")
            .where("entregadorClId", isEqualTo: null)
            .getDocuments())
        .documents;

    if (documentList.isNotEmpty) {
      for (int i = 0; i < documentList.length; i++) {
        OrderPed ped = new OrderPed();
        ped.idPedido = documentList[i].documentID;
        ped.situacao = documentList[i]["situacao"];
        User user = await Util.pesquisaUser(documentList[i]["userClId"]["id"]);
        ped.userClId = user;
        ped.itens = documentList[i]["itens"];
        ped.dataEntregaPed = documentList[i]["dataEntregaPed"];
        ped.latitudeDest = documentList[i]["latitudeDest"];
        ped.longitudeDest = documentList[i]["longitudeDest"];
        ped.longitudeMarketDest = documentList[i]["longitudeMarketDest"];
        ped.latitudeMarketDest = documentList[i]["latitudeMarketDest"];
        ped.numMarketDest = documentList[i]["numMarketDest"];
        ped.dataEntregaPed = documentList[i]["dataEntregaPed"];
        ped.nomeMarket = documentList[i]["nomeMarket"];
        ped.ruaDest = documentList[i]["ruaDest"];
        setState(() {
          possuiLista = true;
          pedidos.add(ped);
        });
      }
    }
    setState(() {
      loadingListas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compra Rápida',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
          child: Container(
        color: Colors.white70,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.lightBlueAccent,
              width: 300,
              child: Column(
                children: [
                  trocaFoto(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${widget.shopper.nome}',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  FlatButton(
                      onPressed: () {},
                      child: PhysicalModel(
                        color: Colors.transparent,
                        child: Text(
                          "Sair",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        elevation: 12,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.chat,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Mensagens",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.monetization_on,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Pagamento",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.list,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Minhas Listas",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.phone,
                size: 40,
                color: Colors.black,
              ),
              title: Text(
                "Contato",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {},
              selected: true,
            ),
          ],
        ),
      )),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 600,
                  width: 600,
                  child: Center(
                    child: Card(
                      elevation: 10,
                      child: Column(
                        children: <Widget>[
                          PhysicalModel(
                            child: Container(
                              child: AppBar(
                                actions: [
                                  IconButton(
                                      onPressed: () {
                                        _trazListas();
                                      },
                                      icon: Icon(Icons.refresh))
                                ],
                                automaticallyImplyLeading: false,
                                title: Text("Listas Recentes:"),
                                backgroundColor: Colors.deepPurple,
                                elevation: 20,
                              ),
                              color: Colors.deepPurple,
                            ),
                            color: Colors.transparent,
                            elevation: 10,
                          ),
                          possuiLista
                              ? Expanded(
                                  child: loadingListas
                                      ? LinearProgressIndicator()
                                      : ListView.builder(
                                          itemCount: pedidos.length,
                                          itemBuilder: (context, i) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => listaInfo(pedidos[i], widget.shopper),
                                                    ));
                                              },
                                              child: Container(
                                                width: 200,
                                                height: 230,
                                                child: Card(
                                                    child: Column(
                                                      children: <Widget> [
                                                        ListTile(
                                                          leading: Icon(Icons.list),
                                                          title: Text("Quantidade de Itens: ${pedidos[i].itens.length}"),
                                                        ),
                                                        ListTile(
                                                          leading: Icon(Icons.shopping_cart),
                                                          title: Text("Super Mercado: ${pedidos[i].nomeMarket}"),
                                                        ),
                                                        ListTile(
                                                          leading: Icon(Icons.calendar_today),
                                                          title: Text("Data: ${formatDate(DateTime.fromMicrosecondsSinceEpoch(pedidos[i].dataHoraPed.microsecondsSinceEpoch), [dd, '/', mm, '/', yyyy])}"),
                                                        ),
                                                        Text("Ver mais...", style: TextStyle(
                                                            color: Colors.lightBlueAccent
                                                        ),),
                                                        SizedBox(
                                                          height: 15,
                                                        )
                                                      ],
                                                    )
                                                ),
                                              ),
                                            );
                                          }))
                              : Container(
                                  width: 200,
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: Center(
                                    child:
                                        Text("Ainda não possui Listas..."),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
