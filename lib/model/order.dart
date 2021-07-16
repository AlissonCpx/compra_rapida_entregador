import 'package:cloud_firestore/cloud_firestore.dart';

import 'destino.dart';
import 'market.dart';
import 'shopper.dart';
import 'user.dart';

class OrderPed {
  User _userClId;
  Shopper _entregadorClId;
  Timestamp _dataHoraPed = Timestamp.now();
  Timestamp _dataEntregaPed;
  List _itens;
  Destino _destino;
  Market _mercado;
  String _situacao;
  double _valorFrete;
  String _nota;
  double _valorNota;
  Map<String, dynamic> toMap(){

    Map<String, dynamic> dadosUser = {
      "id" : this.userClId.idUser,
      "nome" : this.userClId.nome,
      "email" : this.userClId.email,
      "urlImagem" : this.userClId.urlImagem,
      "balance": this.userClId.balance,
      "deliveryman": false,
    };

    Map<String, dynamic> dadosDestino = {
      "rua" : this.destino.rua,
      "numero" : this.destino.numero,
      "bairro" : this.destino.bairro,
      "cep" : this.destino.cep,
      "cidade": this.destino.cidade,
      "latitude": this.destino.latitude,
      "longitude": this.destino.longitude,
    };

    Map<String, dynamic> dadosMercado = {
      "rua" : this.mercado.rua,
      "numero" : this.mercado.numero,
      "bairro" : this.mercado.bairro,
      "cep" : this.mercado.cep,
      "cidade": this.mercado.cidade,
      "latitude": this.mercado.latitude,
      "longitude": this.mercado.longitude,
      "nome": this.mercado.nome,
    };



    Map<String, dynamic> map = {
      "userClId": dadosUser,
      "entregadorClId": this.entregadorClId,
      "dataHoraPed": this.dataHoraPed,
      "dataEntregaPed": this.dataEntregaPed,
      "itens": this.itens,
      "situacao": this.situacao,
      "idPedido" : this.idPedido,
      "destino" : dadosDestino,
      "mercado" : dadosMercado,
      "valorFrete" : this.valorFrete,
      "nota": this.nota,
      "valorNota": this.valorNota
    };

    return map;

  }

  String _idPedido;


  OrderPed();

  String get idPedido => _idPedido;

  set idPedido(String value) {
    _idPedido = value;
  }

  String get situacao => _situacao;

  set situacao(String value) {
    _situacao = value;
  }

  Market get mercado => _mercado;

  set mercado(Market value) {
    _mercado = value;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  List get itens => _itens;

  set itens(List value) {
    _itens = value;
  }

  Timestamp get dataEntregaPed => _dataEntregaPed;

  set dataEntregaPed(Timestamp value) {
    _dataEntregaPed = value;
  }

  Timestamp get dataHoraPed => _dataHoraPed;

  set dataHoraPed(Timestamp value) {
    _dataHoraPed = value;
  }


  Shopper get entregadorClId => _entregadorClId;

  set entregadorClId(Shopper value) {
    _entregadorClId = value;
  }

  User get userClId => _userClId;

  set userClId(User value) {
    _userClId = value;
  }

  String get nota => _nota;

  set nota(String value) {
    _nota = value;
  }

  double get valorFrete => _valorFrete;

  set valorFrete(double value) {
    _valorFrete = value;
  }

  double get valorNota => _valorNota;

  set valorNota(double value) {
    _valorNota = value;
  }
}
