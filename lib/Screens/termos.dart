import 'package:flutter/material.dart';




class TermosContrato extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Termos de Contrato"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              Text("Mussum Ipsum, cacilds vidis litro abertis. Mauris nec dolor in eros commodo tempor. Aenean aliquam molestie leo, vitae iaculis nisl. Atirei o pau no gatis, per gatis num morreus. Suco de cevadiss deixa as pessoas mais interessantis. Praesent vel viverra nisi. Mauris aliquet nunc non turpis scelerisque, eget."

          "Posuere libero varius. Nullam a nisl ut ante blandit hendrerit. Aenean sit amet nisi. Em pé sem cair, deitado sem dormir, sentado sem cochilar e fazendo pose. Nullam volutpat risus nec leo commodo, ut interdum diam laoreet. Sed non consequat odio. Admodum accumsan disputationi eu sit. Vide electram sadipscing et per."

            "Per aumento de cachacis, eu reclamis. Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Leite de capivaris, leite de mula manquis sem cabeça. Diuretics paradis num copo é motivis de denguis."

          "Manduma pindureta quium dia nois paga. Si num tem leite então bota uma pinga aí cumpadi! Paisis, filhis, espiritis santis. Aenean aliquam molestie leo, vitae iaculis nisl."

          "Detraxit consequat et quo num tendi nada. Mais vale um bebadis conhecidiss, que um alcoolatra anonimis. Mé faiz elementum girarzis, nisi eros vermeio. Tá deprimidis, eu conheço uma cachacis que pode alegrar sua vidis.")
            ],
          ),
        ),
      ),
    );
  }
}
