import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/chat_screen.dart';
import 'package:compra_rapida_entregador/Screens/entrega.dart';
import 'package:compra_rapida_entregador/model/order.dart';
import 'package:compra_rapida_entregador/util/util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ComprasMerc extends StatefulWidget {
  @override
  _ComprasMercState createState() => _ComprasMercState();

  String idPedido;
  String idPedidoDocument;

  ComprasMerc(this.idPedido, this.idPedidoDocument);
}

class _ComprasMercState extends State<ComprasMerc> {
  OrderPed order;
  List bollean = [];
  int itensRest;
  final ImagePicker _picker = ImagePicker();
  File nota;
  bool loadingImg = false;
  final valorNotaController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _inicioScreen();
  }

  void _inicioScreen() async {
    OrderPed o = await Util.pesquisaOrder(widget.idPedido);
    setState(() {
      order = o;
      _listFalse();
    });
  }

  void _listFalse() {
    for (int i = 0; i < order.itens.length; i++) {
      bollean.add(false);
    }
    itensRest = order.itens.length;
  }

  void _finalizarCompra(){

    setState(() {
      loading = true;
    });

    if (valorNotaController.text.isNotEmpty && nota != null) {

      double valor = 0;

      if (valorNotaController.text.contains(",")) {
        valor = double.parse(valorNotaController.text.replaceAll(",", "."));
      } else {
        valor = double.parse(valorNotaController.text);
      }

      Firestore db = Firestore.instance;
      db
          .collection("pedidos")
          .document(widget.idPedidoDocument)
          .updateData({
        "valorNota": valor,
      });

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Entrega(widget.idPedidoDocument, order.entregadorClId.idUser),
          ));

    }



    setState(() {
      loading = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Em Compras"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(widget.idPedido,
                          widget.idPedidoDocument, order.entregadorClId.idUser),
                    ));
              },
              icon: Icon(Icons.chat))
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              order != null
                  ? Container(
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
                                title: Text("Lista"),
                                automaticallyImplyLeading: false,
                                actions: <Widget>[],
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: order.itens.length,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                        onChanged: (value) {
                                          setState(() {
                                            bollean.removeAt(index);
                                            bollean.insert(index, value);
                                            if (value) {
                                              itensRest -= 1;
                                            } else {
                                              itensRest += 1;
                                            }
                                          });
                                        },
                                        value: bollean[index],
                                        title: Text(
                                          order.itens[index]["Item"],
                                          maxLines: 1,
                                        ),
                                        subtitle: Text(
                                          order.itens[index]["comment"],
                                          maxLines: 1,
                                        ),
                                      );
                                    }),
                              ),
                              Divider(
                                color: Colors.deepPurple,
                              ),
                              Wrap(
                                children: <Widget>[
                                  Text(
                                      "Quantidade de itens: ${order.itens.length}"),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("itens restantes: ${itensRest}")
                                ],
                              )
                            ],
                          )),
                    )
                  : Center(child: CircularProgressIndicator()),
              Divider(),
              Center(
                child: Text(
                  "Foto da nota:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              nota == null
                  ? Container(
                      width: 300,
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            loadingImg = true;
                          });
                          final imgFile = await _picker.getImage(
                              source: ImageSource.camera);
                          if (imgFile != null) {
                            setState(() {
                              nota = File(imgFile.path);
                            });
                            StorageUploadTask task = FirebaseStorage.instance
                                .ref()
                                .child(DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString())
                                .putFile(nota);

                            StorageTaskSnapshot taskSnapshot =
                                await task.onComplete;
                            String url =
                                await taskSnapshot.ref.getDownloadURL();
                            Firestore db = Firestore.instance;

                            db
                                .collection("pedidos")
                                .document(widget.idPedidoDocument)
                                .updateData({
                              "nota": url,
                            });
                          }
                          setState(() {
                            loadingImg = false;
                          });
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.lightBlueAccent,
                        ),
                        iconSize: 80,
                      ))
                  : Center(
                      child: Card(
                        margin: EdgeInsets.fromLTRB(70, 10, 70, 20),
                        elevation: 10,
                        child: AspectRatio(
                          child: Image.file(nota),
                          aspectRatio: 2,
                        ),
                      ),
                    ),
              loadingImg ? LinearProgressIndicator() : Container(),
              Container(
                width: 300,
                child: TextField(
                  controller: valorNotaController,
                  autofocus: false,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.monetization_on),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Valor Compras:",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              loading ? CircularProgressIndicator() :
              Container(
                  width: 300,
                  height: 30,
                  child: PhysicalModel(
                    color: Colors.transparent,
                    shadowColor: Colors.black,
                    elevation: 8.0,
                    child: RaisedButton(
                      child: Text(
                        'Finalizar Compras',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      textColor: Colors.white,
                      color: Colors.lightBlueAccent,
                      onPressed: () {
                        if (true) {
                          _finalizarCompra();

                        }
                      },
                    ),
                  )),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
