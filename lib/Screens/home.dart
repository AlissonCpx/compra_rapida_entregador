import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/historico.dart';
import 'package:compra_rapida_entregador/Screens/login.dart';
import 'package:compra_rapida_entregador/Screens/pagamento.dart';
import 'package:compra_rapida_entregador/Screens/perfil.dart';
import 'package:compra_rapida_entregador/model/destino.dart';
import 'package:compra_rapida_entregador/model/market.dart';
import 'package:compra_rapida_entregador/model/order.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/model/status.dart';
import 'package:compra_rapida_entregador/model/user.dart';
import 'package:compra_rapida_entregador/util/util.dart';

import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            .where("situacao", isEqualTo: Status.AGUARDANDO)
            .getDocuments())
        .documents;

    if (documentList.isNotEmpty) {
      for (int i = 0; i < documentList.length; i++) {
        OrderPed ped = new OrderPed();
        ped.idPedido = documentList[i].documentID;
        ped.situacao = documentList[i]["situacao"];
        User user = await Util.pesquisaUser(documentList[i]["userClId"]["id"]);
        ped.userClId = user;
        //Shopper shop = await Util.pesquisaShopper(documentList[i]["entregadorClId"]["id"]);
        //ped.entregadorClId = shop;
        ped.itens = documentList[i]["itens"];
        Market merc = await Util.getMercados(documentList[i]["mercado"]["nome"]);
        ped.mercado = merc;
        ped.dataEntregaPed = documentList[i]["dataEntregaPed"];
        ped.dataHoraPed = documentList[i]["dataHoraPed"];
        ped.valorFrete = documentList[i]["valorFrete"];

        Destino dest = new Destino();
        dest.latitude = documentList[i].data["destino"]["latitude"];
        dest.longitude = documentList[i].data["destino"]["longitude"];
        dest.cidade = documentList[i].data["destino"]["cidade"];
        dest.cep = documentList[i].data["destino"]["cep"];
        dest.bairro = documentList[i].data["destino"]["bairro"];
        dest.numero = documentList[i].data["destino"]["numero"];
        dest.rua = documentList[i].data["destino"]["rua"];

        ped.destino = dest;
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
                      onPressed: () {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        auth.signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
                      },
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
                Icons.person,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                "Perfil",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Perfil(widget.shopper),));
              },
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
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Pagamento(widget.shopper.idUser),));
              },
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
                "Histórico",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Historico(widget.shopper.idUser),));
              },
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
                                                        title: Text("Super Mercado: ${pedidos[i].mercado.nome}"),
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
