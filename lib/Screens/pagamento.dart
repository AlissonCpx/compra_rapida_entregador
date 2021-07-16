import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/util/util.dart';
import 'package:flutter/material.dart';







class Pagamento extends StatefulWidget {
  String idShopper;


  Pagamento(this.idShopper);

  @override
  _PagamentoState createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  Shopper shop;


  @override
  void initState() {
super.initState();
    iniciaTela();
  }

  void iniciaTela() async {
    Shopper shopper = await Util.pesquisaShopper(widget.idShopper);
    setState(() {
      shop = shopper;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagamento"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Padding(
                padding: EdgeInsets.all(15),
            child: Text("Saldo R\$: ${shop != null ? shop.balance.toStringAsFixed(2) : ""}"),
            )
          ],
        ),
      ),
    );
  }


}
