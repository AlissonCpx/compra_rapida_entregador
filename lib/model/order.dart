import 'package:cloud_firestore/cloud_firestore.dart';

import 'shopper.dart';
import 'user.dart';

class OrderPed {

  User _userClId;
  Shopper _entregadorClId;
  Timestamp _dataHoraPed = Timestamp.now();
  Timestamp _dataEntregaPed = Timestamp.now();
  List _itens;
  String _ruaDest;
  String _numDest;
  double _longitudeDest;
  double _latitudeDest;
  String _ruaMarketDest;
  String _numMarketDest;
  String _nomeMarket;
  double _longitudeMarketDest;
  double _latitudeMarketDest;
  String _situacao;
  String _idPedido;

  OrderPed();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "userClId": this.userClId,
      "entregadorClId": this.entregadorClId,
      "dataHoraPed": this.dataHoraPed,
      "dataEntregaPed": this.dataEntregaPed,
      "itens": this.itens,
      "ruaDest": this.ruaDest,
      "numDest": this.numDest,
      "longitudeDest": this.longitudeDest,
      "latitudeDest": this.latitudeDest,
      "ruaMarketDest": this.ruaMarketDest,
      "numMarketDest": this.numMarketDest,
      "nomeMarket": this.nomeMarket,
      "longitudeMarketDest": this.longitudeMarketDest,
      "latitudeMarketDest": this.latitudeMarketDest,
      "situacao": this.situacao,
      "idPedido": this.idPedido,
    };

    return map;
  }

  String get situacao => _situacao;

  set situacao(String value) {
    _situacao = value;
  }

  double get latitudeMarketDest => _latitudeMarketDest;

  set latitudeMarketDest(double value) {
    _latitudeMarketDest = value;
  }

  double get longitudeMarketDest => _longitudeMarketDest;

  set longitudeMarketDest(double value) {
    _longitudeMarketDest = value;
  }

  String get nomeMarket => _nomeMarket;

  set nomeMarket(String value) {
    _nomeMarket = value;
  }

  String get numMarketDest => _numMarketDest;

  set numMarketDest(String value) {
    _numMarketDest = value;
  }

  String get ruaMarketDest => _ruaMarketDest;

  set ruaMarketDest(String value) {
    _ruaMarketDest = value;
  }

  double get latitudeDest => _latitudeDest;

  set latitudeDest(double value) {
    _latitudeDest = value;
  }

  double get longitudeDest => _longitudeDest;

  set longitudeDest(double value) {
    _longitudeDest = value;
  }

  String get numDest => _numDest;

  set numDest(String value) {
    _numDest = value;
  }

  String get ruaDest => _ruaDest;

  set ruaDest(String value) {
    _ruaDest = value;
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


  User get userClId => _userClId;

  set userClId(User value) {
    _userClId = value;
  }

  String get idPedido => _idPedido;

  set idPedido(String value) {
    _idPedido = value;
  }

  Shopper get entregadorClId => _entregadorClId;

  set entregadorClId(Shopper value) {
    _entregadorClId = value;
  }
}
