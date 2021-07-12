import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/model/order.dart';
import 'package:compra_rapida_entregador/model/shopper.dart';
import 'package:compra_rapida_entregador/model/user.dart';
import 'package:flutter/material.dart';





class Util {

  static Future<User> pesquisaUser(String idUser) async {
    User user = new User();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("usuarios")
        .where("id", isEqualTo: idUser)
        .getDocuments())
        .documents;
    if (documentList != null) {
      user.nome = documentList[0]["nome"];
      user.email = documentList[0]["email"];
      user.deliveryman = documentList[0]["deliveryman"];
      user.balance = documentList[0]["balance"];
      user.idUser = documentList[0]["id"];
      user.urlImagem = documentList[0]["urlImagem"];
    }
    return user;
  }

  static Future<Shopper> pesquisaShopper(String idShopper) async {
    Shopper shopper = new Shopper();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("shoppers")
        .where("id", isEqualTo: idShopper)
        .getDocuments())
        .documents;
    if (documentList != null) {
      shopper.nome = documentList[0]["nome"];
      shopper.email = documentList[0]["email"];
      shopper.deliveryman = documentList[0]["deliveryman"];
      shopper.balance = documentList[0]["balance"];
      shopper.idUser = documentList[0]["id"];
      shopper.foto = documentList[0]["foto"];
      shopper.fotoCNH = documentList[0]["fotoCNH"];
      shopper.fotoCRLV = documentList[0]["fotoCRLV"];
    }
    return shopper;
  }

  static Future<OrderPed> pesquisaOrder(String idOrder) async {
    OrderPed ped = new OrderPed();
    List<DocumentSnapshot> documentList;
    documentList = (await Firestore.instance
        .collection("pedidos")
        .where("idPedido", isEqualTo: idOrder)
        .getDocuments())
        .documents;
    if (documentList != null) {
      ped.idPedido = documentList[0].documentID;
      ped.situacao = documentList[0]["situacao"];
      User user = await Util.pesquisaUser(documentList[0]["userClId"]["id"]);
      ped.userClId = user;
      Shopper shop = await Util.pesquisaShopper(documentList[0]["entregadorClId"]["id"]);
      ped.entregadorClId = shop;
      ped.itens = documentList[0]["itens"];
      ped.dataEntregaPed = documentList[0]["dataEntregaPed"];
      ped.latitudeDest = documentList[0]["latitudeDest"];
      ped.longitudeDest = documentList[0]["longitudeDest"];
      ped.longitudeMarketDest = documentList[0]["longitudeMarketDest"];
      ped.latitudeMarketDest = documentList[0]["latitudeMarketDest"];
      ped.numMarketDest = documentList[0]["numMarketDest"];
      ped.dataEntregaPed = documentList[0]["dataEntregaPed"];
      ped.nomeMarket = documentList[0]["nomeMarket"];
      ped.ruaDest = documentList[0]["ruaDest"];
    }
    return ped;
  }

  static atualizarDadosLocalizacao(String idRequisicao, double lat, double lon, String tipo, String userId) async {

    Firestore db = Firestore.instance;

    User user = await pesquisaUser(userId);
    //user.latitude = lat;
    //user.longitude = lon;

    db.collection("pedidos")
        .document( idRequisicao )
        .updateData({
      "${tipo}" : user.toMap()
    });

  }





}