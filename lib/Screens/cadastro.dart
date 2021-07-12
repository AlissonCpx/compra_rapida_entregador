import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/termos.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmController = TextEditingController();
  final dtNascController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formkey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  File cnh;
  File crlv;
  File perfil;
  bool aceitaTermos = false;
  bool loading = false;

  void onSuccess() {
    Alert(
        context: context,
        title: "Cadastro Efetuado com Sucesso!",
        desc:
            "Seu cadastro foi enviado para a equipe de análise.\nDentre o periodo de 42 horas voce receberá o resultado da análise em seu e-mail.",
        buttons: [
          DialogButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
        ]).show();
  }

  void onAlert(String mensagem) {
    Alert(context: context, title: "Erro!", desc: mensagem, buttons: [
      DialogButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          }),
    ]).show();
  }

  void onFail() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao criar usuário"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  bool validaFotos() {
    if (cnh == null) {
      onAlert("A foto da CNH é obrigatória!");
      return false;
    }
    if (crlv == null) {
      onAlert("A foto da CRLV é obrigatória!");
      return false;
    }
    if (perfil == null) {
      onAlert("A foto de Perfil é obrigatória!");
      return false;
    }
    if (!aceitaTermos) {
      onAlert("Deve aceitar os termos!");
      return false;
    }
    return true;
  }

  void signInAnonymously() async {
    FirebaseAuth mAuth = FirebaseAuth.instance;
    await mAuth.signInAnonymously();
  }

  _cadastraShopper() async {
    Shopper shopper = new Shopper();



    if (validaFotos()) {
      setState(() {
        loading = true;
      });
      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.signInWithEmailAndPassword(
          email: "equipecr@gmail.com", password: "123456");

      if (cnh != null && crlv != null && perfil != null) {
        //signInAnonymously();
        StorageUploadTask task = FirebaseStorage.instance
            .ref()
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(perfil);
        StorageUploadTask task2 = FirebaseStorage.instance
            .ref()
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(cnh);
        StorageUploadTask task3 = FirebaseStorage.instance
            .ref()
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(crlv);

        StorageTaskSnapshot taskSnapshot = await task.onComplete;
        StorageTaskSnapshot taskSnapshot2 = await task2.onComplete;
        StorageTaskSnapshot taskSnapshot3 = await task3.onComplete;
        String urlPerfil = await taskSnapshot.ref.getDownloadURL();
        String urlCnh = await taskSnapshot2.ref.getDownloadURL();
        String urlCrlv = await taskSnapshot3.ref.getDownloadURL();
        auth.signOut();

        shopper.nome = nomeController.text;
        shopper.email = emailController.text;
        shopper.foto = urlPerfil;
        shopper.fotoCNH = urlCnh;
        shopper.fotoCRLV = urlCrlv;
        shopper.balance = 0;

        auth
            .createUserWithEmailAndPassword(
          email: shopper.email,
          password: senhaController.text,
        )
            .then((firebaseUser) {
          //Salvar dados do usuário
          Firestore db = Firestore.instance;
          shopper.idUser = firebaseUser.user.uid;
          db
              .collection("shoppers")
              .document(firebaseUser.user.uid)
              .setData(shopper.toMap());
          setState(() {
            // loading = false;
          });
          onSuccess();
        }).catchError((e) {
          //onFail();
        });
      }

      auth
          .createUserWithEmailAndPassword(
              email: shopper.email, password: shopper.senha)
          .then((firebaseUser) {
        //Salvar dados do usuário
        Firestore db = Firestore.instance;
        shopper.idUser = firebaseUser.user.uid;
        db
            .collection("usuarios")
            .document(firebaseUser.user.uid)
            .setData(shopper.toMap());
        onSuccess();
      }).catchError((e) {
        //onFail();
      });

      setState(() {
        loading = false;
      });
    }
  }

  void showOptions(BuildContext context, String tipo) {
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
                                      setState(() {
                                        if (tipo == "cnh") {
                                          cnh = File(imgFile.path);
                                        } else if (tipo == "crlv") {
                                          crlv = File(imgFile.path);
                                        } else {
                                          perfil = File(imgFile.path);
                                        }
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
                                      setState(() {
                                        if (tipo == "cnh") {
                                          cnh = File(imgFile.path);
                                        } else if (tipo == "crlv") {
                                          crlv = File(imgFile.path);
                                        } else {
                                          perfil = File(imgFile.path);
                                        }
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

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      confirmText: "Ok",
      cancelText: "Cancelar",
      helpText: "Selecione a data de nascimento",
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2022),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        dtNascController.text = formatDate(picked, [dd, '/', mm, '/', yyyy]);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Cadastro"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
                key: formkey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        autofocus: false,
                        controller: nomeController,
                        decoration: InputDecoration(
                            hintText: 'Nome Completo',
                            labelStyle: TextStyle(color: Colors.redAccent)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Digite o seu nome completo";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        autofocus: false,
                        controller: emailController,
                        decoration: InputDecoration(
                            hintText: 'Email',
                            labelStyle: TextStyle(color: Colors.redAccent)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Digite o seu email";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        obscureText: true,
                        autofocus: false,
                        controller: senhaController,
                        decoration: InputDecoration(
                            hintText: 'Senha',
                            labelStyle: TextStyle(color: Colors.redAccent)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Digite a senha";
                          } else if (value.length <= 6) {
                            return "Digite no minimo 6 caracteres";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        obscureText: true,
                        autofocus: false,
                        controller: confirmController,
                        decoration: InputDecoration(
                            hintText: 'Confirmar Senha',
                            labelStyle: TextStyle(color: Colors.redAccent)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "Digite a senha novamente";
                          } else if (value != senhaController.text) {
                            return "As senhas tem que ser iguais";
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextFormField(
                            enabled: false,
                            readOnly: true,
                            obscureText: false,
                            autofocus: false,
                            controller: dtNascController,
                            decoration: InputDecoration(
                                hintText: 'Data Nascimento',
                                labelStyle: TextStyle(color: Colors.redAccent)),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Preencha a data de nascimento";
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            AppBar(
                              backgroundColor: Colors.lightBlueAccent,
                              automaticallyImplyLeading: false,
                              centerTitle: true,
                              title: Text("Fotos"),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      showOptions(context, "perfil");
                                    },
                                    child: perfil != null
                                        ? Container(
                                            child: Image.file(perfil),
                                          )
                                        : Container(
                                            width: 150.0,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.lightBlueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Column(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.camera_alt,
                                                  size: 30,
                                                ),
                                                Text("Perfil")
                                              ],
                                            ),
                                          ),
                                  ),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      showOptions(context, "cnh");
                                    },
                                    child: cnh != null
                                        ? Container(
                                            child: Image.file(cnh),
                                          )
                                        : Container(
                                            width: 150.0,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.lightBlueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Column(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.camera_alt,
                                                  size: 30,
                                                ),
                                                Text("CNH")
                                              ],
                                            ),
                                          ),
                                  ),
                                )),
                                Expanded(
                                    child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      showOptions(context, "crlv");
                                    },
                                    child: crlv != null
                                        ? Container(
                                            child: Image.file(crlv),
                                          )
                                        : Container(
                                            width: 150.0,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.lightBlueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Column(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.camera_alt,
                                                  size: 30,
                                                ),
                                                Text("CRLV")
                                              ],
                                            ),
                                          ),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: aceitaTermos,
                          activeColor: Colors.lightBlueAccent,
                          onChanged: (value) {
                            setState(() {
                              aceitaTermos = value;
                            });
                          },
                        ),
                        Text("Clique para aceitar os "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TermosContrato(),
                                ));
                          },
                          child: Text(
                            "termos.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue),
                          ),
                        )
                      ],
                    ),
                    loading
                        ? CircularProgressIndicator()
                        : Container(
                            width: 300,
                            child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
                                child: RaisedButton(
                                    child: Text(
                                      'Cadastrar',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    textColor: Colors.white,
                                    color: Colors.lightBlueAccent,
                                    onPressed: () {
                                      if (formkey.currentState.validate()) {
                                        _cadastraShopper();
                                      }
                                    })),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
