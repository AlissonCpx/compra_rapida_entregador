import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/trocarsenha.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';





class Perfil extends StatefulWidget {
  Shopper user;


  Perfil(this.user);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {

  final nomeController = TextEditingController();
  final numeroController = TextEditingController();

  var maskFormatter = new MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });
  final ImagePicker _picker = ImagePicker();
  File foto;
  bool loadingFoto = false;
  String url;
  bool alterado = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  void onSucess() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Dados alterado com sucesso!"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }



  void foialterado() {
    setState(() {
      alterado = true;
    });
  }


  void showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () async {
                                        final imgFile = await _picker.getImage(
                                            source: ImageSource.camera);
                                        if (imgFile != null) {
                                          foto = File(imgFile.path);
                                          setState(() {
                                            loadingFoto = true;
                                          });

                                          StorageUploadTask task = FirebaseStorage.instance
                                              .ref()
                                              .child(DateTime.now().millisecondsSinceEpoch.toString())
                                              .putFile(foto);

                                          StorageTaskSnapshot taskSnapshot = await task.onComplete;
                                          String urlFoto = await taskSnapshot.ref.getDownloadURL();

                                          setState(() {
                                            url = urlFoto;
                                            loadingFoto = false;
                                          });



                                          Navigator.pop(context);
                                        }
                                      }),
                                  Text("Camera")
                                ],
                              )),
                          Expanded(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.photo),
                                      onPressed: () async {
                                        final imgFile = await _picker.getImage(
                                            source: ImageSource.gallery);
                                        if (imgFile != null) {
                                          foto = File(imgFile.path);
                                          setState(() {
                                            loadingFoto = true;
                                          });

                                          StorageUploadTask task = FirebaseStorage.instance
                                              .ref()
                                              .child(DateTime.now().millisecondsSinceEpoch.toString())
                                              .putFile(foto);

                                          StorageTaskSnapshot taskSnapshot = await task.onComplete;
                                          String urlFoto = await taskSnapshot.ref.getDownloadURL();

                                          Firestore db = Firestore.instance;
                                          db
                                              .collection("shoppers")
                                              .document(widget.user.idUser)
                                              .updateData({"foto": urlFoto});

                                          setState(() {
                                            url = urlFoto;
                                            loadingFoto = false;
                                          });
                                          Navigator.pop(context);
                                        }
                                      }),
                                  Text("Galeria")
                                ],
                              ))
                        ],
                      )
                    ],
                  ),
                );
              });
        });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save, size: 40,),
        backgroundColor: alterado ? Colors.lightBlueAccent : Colors.grey,
        onPressed: alterado ? () {
          if (nomeController.text.isNotEmpty) {

            Firestore db = Firestore.instance;
            db
                .collection("shoppers")
                .document(widget.user.idUser)
                .updateData({"nome": nomeController.text});


          }

          if (numeroController.text.isNotEmpty) {

            Firestore db = Firestore.instance;
            db
                .collection("shoppers")
                .document(widget.user.idUser)
                .updateData({"phone": maskFormatter.getUnmaskedText()});


          }

        onSucess();


        } : null,
      ),
      appBar: AppBar(
        title: Text("Perfil"),
        centerTitle: true,
      ),

      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              SizedBox(
                height: 10,
              ),
          Center(
            child: GestureDetector(
              onTap: () {
                showOptions(context);
              },
              child: Container(
                  margin: EdgeInsets.zero,
                  height: 200,
                  width: 200,
                  child: loadingFoto ? CircularProgressIndicator() : CircleAvatar(
                    backgroundImage: NetworkImage(url != null ? url : widget.user.foto),
                  )),
            ),
          ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: nomeController,
                  autofocus: false,
                  onChanged: (value) {
                    foialterado();
                  },
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "${widget.user.nome}",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 300,
                child: TextField(
                  readOnly: true,
                  controller: null,
                  autofocus: false,
                  style: TextStyle(fontSize: 16),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "${widget.user.email}",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 300,
                child: TextField(
                  controller:  numeroController,
                  autofocus: false,
                  onChanged: (value) {
                    foialterado();
                  },
                  style: TextStyle(fontSize: 16),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [maskFormatter],
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "${maskFormatter.maskText(widget.user.phone)}",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              SizedBox(
                height: 10,
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
                        'Alterar Senha',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      textColor: Colors.white,
                      color: Colors.redAccent,
                      onPressed: () {
                        if (true) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TrocaSenha(email: widget.user.email),));
                        }
                      },
                    ),
                  )),

              Divider(),
              RatingBar.builder(
                initialRating: widget.user.rate,
                direction: Axis.horizontal,
                allowHalfRating: false,
                ignoreGestures: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),

              ),

            ],
          ),
        ),
      ),
    );
  }
}
