
class Shopper {
  String _idUser;
  String _nome;
  String _email;
  String _foto;
  String _fotoCRLV;
  String _fotoCNH;
  String _senha;
  double _balance = 0;
  bool _deliveryman;


  Shopper();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "id" : this.idUser,
      "nome" : this.nome,
      "email" : this.email,
      "foto" : this.foto,
      "fotoCRLV" : this.fotoCRLV,
      "fotoCNH" : this.fotoCNH,
      "balance": this.balance,
      "deliveryman": false,
    };

    return map;

  }

  bool get deliveryman => _deliveryman;

  set deliveryman(bool value) {
    _deliveryman = value;
  }

  double get balance => _balance;

  set balance(double value) {
    _balance = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get fotoCNH => _fotoCNH;

  set fotoCNH(String value) {
    _fotoCNH = value;
  }

  String get fotoCRLV => _fotoCRLV;

  set fotoCRLV(String value) {
    _fotoCRLV = value;
  }

  String get foto => _foto;

  set foto(String value) {
    _foto = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }
}