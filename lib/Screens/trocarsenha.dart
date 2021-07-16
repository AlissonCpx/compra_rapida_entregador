import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrocaSenha extends StatefulWidget {
  String email;

  TrocaSenha({this.email});

  @override
  _TrocaSenhaState createState() => _TrocaSenhaState();
}

class _TrocaSenhaState extends State<TrocaSenha> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final emailController = TextEditingController();

  @override
  void initState() {
    emailController.text = widget.email;
  }

  void onFail() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("O Campo Email deve estar preenchido!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  void onSucess() {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Acesse seu email para redefinir a senha!"),
      backgroundColor: Colors.greenAccent,
      duration: Duration(seconds: 2),
    ));
  }

  void redefinirSenha() async {
    if (emailController.text.isNotEmpty) {
      FirebaseAuth auth = FirebaseAuth.instance;

      auth.sendPasswordResetEmail(email: emailController.text);

      onSucess();
    } else {
      onFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.email != null ? "Redefinir Senha" : "Recuperar Senha"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: 350,
              child: TextField(
                controller: emailController,
                autofocus: false,
                style: TextStyle(fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText:
                        "${widget.email != null ? widget.email : "Email"}",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
                width: 300,
                height: 30,
                child: PhysicalModel(
                  color: Colors.transparent,
                  shadowColor: Colors.black,
                  elevation: 8.0,
                  child: RaisedButton(
                    child: Text(
                      'Enviar',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    onPressed: () {
                      if (true) {
                        redefinirSenha();
                      }
                    },
                  ),
                )),
          )
        ],
      ),
    );
  }
}
