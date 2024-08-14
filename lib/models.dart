class MerchantUser {
  final int idMerchant;
  final String nomComplet;
  final String email;
  final String solde;

  MerchantUser({
    required this.idMerchant,
    required this.nomComplet,
    required this.email,
    required this.solde,
  });

  factory MerchantUser.fromJson(Map<String, dynamic> json) {
    return MerchantUser(
      idMerchant: json['specialId'],
      nomComplet: json['nomComplet'],
      email: json['email'],
      solde: json['solde'],
    );
  }
}

class History {
  final int id;
  final int idMerchant;
  final String action;
  final double montant;
  final String date;

  History({
    required this.id,
    required this.idMerchant,
    required this.action,
    required this.montant,
    required this.date,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      idMerchant: json['idMerchant'],
      action: json['action'],
      montant: json['montant'].toDouble(),
      date: json['date'],
    );
  }
}
