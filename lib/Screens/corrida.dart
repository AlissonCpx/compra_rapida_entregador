
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compra_rapida_entregador/model/status.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';


class Corrida extends StatefulWidget {

  String idPedido;

  Corrida( this.idPedido );

  @override
  _CorridaState createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera =
  CameraPosition(target: LatLng(-23.563999, -46.653256));
  Set<Marker> _marcadores = {};
  Map<String, dynamic> _dadosRequisicao;
  String _idRequisicao;
  Position _localMotorista;
  String _statusRequisicao = Status.AGUARDANDO;

  //Controles para exibição na tela
  String _textoBotao = "Aceitar corrida";
  Color _corBotao = Color(0xff1ebbd8);
  Function _funcaoBotao;
  String _mensagemStatus = "";

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void recuperaLocAtual() async{
    var geolocator = Geolocator();
    Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _localMotorista = position;
    });
  }

  _adicionarListenerLocalizacao() async {
    var geolocator = Geolocator();
    var locationOptions =
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);



    geolocator.getPositionStream(locationOptions).listen((Position position) {
      //Position position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _localMotorista = position;
      });

    });


    _statusAguardando();


  }

  _recuperaUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (position != null) {

      //Atualizar localização em tempo real do motorista


    }

  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _exibirMarcador(Position local, String icone, String infoWindow) async {

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: infoWindow),
          icon: bitmapDescriptor);

      setState(() {
        _marcadores.add(marcador);
      });
    });


  }

  _recuperarRequisicao() async {

    String idRequisicao = widget.idPedido;

    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot = await db
        .collection("requisicoes")
        .document( idRequisicao )
        .get();




  }

  _adicionarListenerRequisicao() async {

    Firestore db = Firestore.instance;

    await db.collection("pedidos")
    .document( widget.idPedido ).snapshots().listen((snapshot){

      if( snapshot.data != null ){

        _dadosRequisicao = snapshot.data;

        Map<String, dynamic> dados = snapshot.data;
        _statusRequisicao = dados["status"];

        switch( _statusRequisicao ){
          case Status.AGUARDANDO :
            _statusAguardando();
            break;
          case Status.A_CAMINHO :
            _statusACaminho();
            break;
          case Status.VIAGEM :
            _statusEmViagem();
            break;
          case Status.FINALIZADA :
            _statusFinalizada();
            break;
          case Status.CONFIRMADA :
            _statusConfirmada();
            break;

        }

      }

    });

  }

  _statusAguardando() {

    _alterarBotaoPrincipal(
        "Aceitar corrida",
        Color(0xff1ebbd8),
            () {
          _aceitarCorrida();
        });

    if( _localMotorista != null ){

      double motoristaLat = _localMotorista.latitude;
      double motoristaLon = _localMotorista.longitude;

      Position position = Position(
          latitude: motoristaLat, longitude: motoristaLon
      );
      _exibirMarcador(
          position,
          "imagens/motorista.png",
          "Motorista"
      );

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);

      _movimentarCamera( cameraPosition );

    }

  }

  _statusACaminho() {

    _mensagemStatus = "A caminho do passageiro";
    _alterarBotaoPrincipal(
        "Iniciar corrida",
        Color(0xff1ebbd8),
        (){
          _iniciarCorrida();
        }
    );


    double latitudePassageiro = _dadosRequisicao["latitudeDest"];
    double longitudePassageiro = _dadosRequisicao["longitudeDest"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    double latitudeMercado = _dadosRequisicao["latitudeMarketDest"];
    double longitudeMercado = _dadosRequisicao["latitudeMarketDest"];

    //Exibir dois marcadores
    _exibirTresMarcadores(
      LatLng(latitudeMotorista, longitudeMotorista),
      LatLng(latitudePassageiro, longitudePassageiro),
      LatLng(latitudeMercado, longitudeMercado)
    );

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if( latitudeMotorista <=  latitudePassageiro ){
      sLat = latitudeMotorista;
      nLat = latitudePassageiro;
    }else{
      sLat = latitudePassageiro;
      nLat = latitudeMotorista;
    }

    if( longitudeMotorista <=  longitudePassageiro ){
      sLon = longitudeMotorista;
      nLon = longitudePassageiro;
    }else{
      sLon = longitudePassageiro;
      nLon = longitudeMotorista;
    }
    //-23.560925, -46.650623
    _movimentarCameraBounds(
      LatLngBounds(
          northeast: LatLng(nLat, nLon), //nordeste
          southwest: LatLng(sLat, sLon) //sudoeste
      )
    );

  }

  _finalizarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("pedidos")
    .document( widget.idPedido )
    .updateData({
      "status" : Status.FINALIZADA
    });


  }

  _statusFinalizada() async {

    //Calcula valor da corrida
    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    double distanciaEmMetros = await Geolocator().distanceBetween(
        latitudeOrigem,
        longitudeOrigem,
        latitudeDestino,
        longitudeDestino
    );

    //Converte para KM
    double distanciaKm = distanciaEmMetros / 1000;

    //8 é o valor cobrado por KM
    double valorViagem = distanciaKm * 8;

    //Formatar valor viagem
    var f = new NumberFormat("#,##0.00", "pt_BR");
    var valorViagemFormatado = f.format( valorViagem );

    _mensagemStatus = "Viagem finalizada";
    _alterarBotaoPrincipal(
        "Confirmar - R\$ ${valorViagemFormatado}",
        Color(0xff1ebbd8),
            (){
          _confirmarCorrida();
        }
    );

    _marcadores = {};
    Position position = Position(
        latitude: latitudeDestino, longitude: longitudeDestino
    );
    _exibirMarcador(
        position,
        "imagens/destino.png",
        "Destino"
    );

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);

    _movimentarCamera( cameraPosition );

  }

  _statusConfirmada(){

    Navigator.pushReplacementNamed(context, "/painel-motorista");

  }

  _confirmarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("pedidos")
        .document( widget.idPedido )
        .updateData({
      "status" : Status.CONFIRMADA
    });
  }

  _statusEmViagem() {

    _mensagemStatus = "Em viagem";
    _alterarBotaoPrincipal(
        "Finalizar corrida",
        Color(0xff1ebbd8),
            (){
          _finalizarCorrida();
        }
    );


    double latitudeDestino = _dadosRequisicao["latitudeDest"];
    double longitudeDestino = _dadosRequisicao["longitudeDest"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];

    //Exibir dois marcadores
    _exibirDoisMarcadores(
        LatLng(latitudeOrigem, longitudeOrigem),
        LatLng(latitudeDestino, longitudeDestino)
    );

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if( latitudeOrigem <=  latitudeDestino ){
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    }else{
      sLat = latitudeDestino;
      nLat = latitudeOrigem;
    }

    if( longitudeOrigem <=  longitudeDestino ){
      sLon = longitudeOrigem;
      nLon = longitudeDestino;
    }else{
      sLon = longitudeDestino;
      nLon = longitudeOrigem;
    }
    //-23.560925, -46.650623
    _movimentarCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon), //nordeste
            southwest: LatLng(sLat, sLon) //sudoeste
        )
    );

  }

  _iniciarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("requisicoes")
    .document( _idRequisicao )
    .updateData({
      "status" : Status.VIAGEM
    });


  }

  _movimentarCameraBounds(LatLngBounds latLngBounds) async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(
      CameraUpdate.newLatLngBounds(
          latLngBounds,
          100
      )
    );

  }

  _exibirDoisMarcadores(LatLng latLngMotorista, LatLng latLngPassageiro){

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/motorista.png")
        .then((BitmapDescriptor icone) {
      Marker marcador1 = Marker(
          markerId: MarkerId("marcador-motorista"),
          position: LatLng(latLngMotorista.latitude, latLngMotorista.longitude),
          infoWindow: InfoWindow(title: "Local motorista"),
          icon: icone);
      _listaMarcadores.add( marcador1 );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcador2 = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(latLngPassageiro.latitude, latLngPassageiro.longitude),
          infoWindow: InfoWindow(title: "Local passageiro"),
          icon: icone);
      _listaMarcadores.add( marcador2 );
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }

  _exibirTresMarcadores(LatLng latLngMotorista, LatLng latLngPassageiro, LatLng latLngMercado){

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/motorista.png")
        .then((BitmapDescriptor icone) {
      Marker marcador1 = Marker(
          markerId: MarkerId("marcador-motorista"),
          position: LatLng(latLngMotorista.latitude, latLngMotorista.longitude),
          infoWindow: InfoWindow(title: "Local motorista"),
          icon: icone);
      _listaMarcadores.add( marcador1 );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcador2 = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(latLngPassageiro.latitude, latLngPassageiro.longitude),
          infoWindow: InfoWindow(title: "Local passageiro"),
          icon: icone);
      _listaMarcadores.add( marcador2 );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/mercado.png")
        .then((BitmapDescriptor icone) {
      Marker marcador3 = Marker(
          markerId: MarkerId("marcador-mercado"),
          position: LatLng(latLngMercado.latitude, latLngMercado.longitude),
          infoWindow: InfoWindow(title: "Local passageiro"),
          icon: icone);
      _listaMarcadores.add( marcador3 );
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }

  _aceitarCorrida() async {

    Firestore db = Firestore.instance;

      //Salvar requisicao ativa para motorista
      db.collection("pedidos")
          .document( widget.idPedido )
          .setData({
        "status" : Status.A_CAMINHO,
      });
    

  }

  @override
  void initState() {
    super.initState();

    _idRequisicao = widget.idPedido;

    // adicionar listener para mudanças na requisicao
    _adicionarListenerRequisicao();
    recuperaLocAtual();
    //_recuperaUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();

   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel corrida - " + _mensagemStatus ),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
              //-23,559200, -46,658878
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                    : EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      _textoBotao,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: _corBotao,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: _funcaoBotao),
              ),
            )
          ],
        ),
      ),
    );
  }
}
