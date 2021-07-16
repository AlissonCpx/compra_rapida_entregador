import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/cadastro.dart';
import 'package:compra_rapida_entregador/Screens/home.dart';
import 'package:compra_rapida_entregador/Screens/trocarsenha.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formkey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;

  void onFail() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao fazer login!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  _efetuaLogin() {
    setState(() {
      loading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: emailController.text, password: senhaController.text)
        .then((firebaseUser) async {
      Shopper shopper = new Shopper();


      shopper = await Util.pesquisaShopper(firebaseUser.user.uid);


      if (shopper.deliveryman) {
         Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(shopper),
            ));
      } else {
        Alert(
            context: context,
            title: "Em Análise!",
            desc: "Seu cadastro ainda está em análise!",
            buttons: [
              DialogButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ]).show();
      }

      setState(() {
        loading = false;
      });
    }).catchError((onError) {
      print(onError);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                  child: Image.asset(
                "imagens/logo.png",
                height: 350,
                width: 350,
              )),
              Form(
                key: formkey,
                child: Column(
                  children: <Widget>[
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
                            return "Insira o email";
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
                            return "Insira o senha";
                          }
                        },
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 255,
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TrocaSenha(),));
                          },
                          child: Text('Esqueceu a senha?'),
                        ),
                      ],
                    ),
                    loading
                        ? CircularProgressIndicator()
                        : Container(
                            width: 300,
                            height: 30,
                            child: PhysicalModel(
                              color: Colors.transparent,
                              shadowColor: Colors.black,
                              elevation: 8.0,
                              child: RaisedButton(
                                child: Text(
                                  'Entrar',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.white,
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (formkey.currentState.validate()) {
                                    _efetuaLogin();
                                  }
                                },
                              ),
                            )),
                    SizedBox(
                      height: 15,
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cadastro(),
                            ));
                      },
                      child: Text('Criar Conta'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
