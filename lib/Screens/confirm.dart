import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/Screens/home.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/model/status.dart';
import 'package:compra_rapida_entregador/util/util.dart';
import 'package:flutter/material.dart';



class Confirmacao extends StatefulWidget {

  String idPedido;

  Confirmacao(this.idPedido);

  @override
  _ConfirmacaoState createState() => _ConfirmacaoState();
}

class _ConfirmacaoState extends State<Confirmacao> {


  _adicionarListenerRequisicao() async {
    Firestore db = Firestore.instance;

    await db
        .collection("pedidos")
        .document(widget.idPedido)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data != null) {

        Map<String, dynamic> dados = snapshot.data;

        if(dados["situacao"] == Status.ENTREGUE) {

          Shopper shopper = await Util.pesquisaShopper(dados["entregadorClId"]["id"]);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(shopper),
              ));
        }

      }
    });
  }


  @override
  void initState() {
    super.initState();
    _adicionarListenerRequisicao();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Aguardando confirmação"),
      ),
      body: Container(
        height: double.infinity / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Container(
              height: 200,
              width: 200,
              child:  CircularProgressIndicator(

              ),
            ),

            SizedBox(
              height: 40,
            ),

            Center(
              child: Text("Aguardando confirmação do cliente!", style: TextStyle(
                fontSize: 16
              ),),
            )
          ],
        ),
      ),
    );
  }
}
