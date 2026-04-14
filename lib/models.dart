import 'package:flutter/material.dart';

enum DemandeStatus { enAttente, acceptee, refusee }

class Bon {
  String numBon;
  String annee;
  String fournisseur;
  String? objet;
  String? imagePath;
  
  Bon({required this.numBon, required this.annee, required this.fournisseur, this.objet, this.imagePath});

  Map<String, dynamic> toMap() => {
    'numBon': numBon,
    'annee': annee,
    'fournisseur': fournisseur,
    'objet': objet,
    'imagePath': imagePath,
  };

  factory Bon.fromMap(Map<String, dynamic> map) => Bon(
    numBon: map['numBon'],
    annee: map['annee'],
    fournisseur: map['fournisseur'],
    objet: map['objet'],
    imagePath: map['imagePath'],
  );
}

class Produit {
  String designation;
  int quantite;
  double prixUnitaire;
  String? numBon; // Ajout du lien vers le bon

  Produit({required this.designation, required this.quantite, required this.prixUnitaire, this.numBon});
  double get totalTTC => quantite * prixUnitaire * 1.2;

  Map<String, dynamic> toMap() => {
    'designation': designation,
    'quantite': quantite,
    'prixUnitaire': prixUnitaire,
    'numBon': numBon,
  };

  factory Produit.fromMap(Map<String, dynamic> map) => Produit(
    designation: map['designation'],
    quantite: map['quantite'],
    prixUnitaire: map['prixUnitaire'],
    numBon: map['numBon'],
  );
}

class Bureau {
  String nom;
  Bureau({required this.nom});

  Map<String, dynamic> toMap() => { 'nom': nom };
  factory Bureau.fromMap(Map<String, dynamic> map) => Bureau(nom: map['nom']);
}

class Consommation {
  int? id;
  String bureauNom;
  String produitNom;
  int quantite;
  String date;
  Consommation({this.id, required this.bureauNom, required this.produitNom, required this.quantite, required this.date});

  Map<String, dynamic> toMap() => {
    'id': id,
    'bureauNom': bureauNom,
    'produitNom': produitNom,
    'quantite': quantite,
    'date': date,
  };

  factory Consommation.fromMap(Map<String, dynamic> map) => Consommation(
    id: map['id'],
    bureauNom: map['bureauNom'],
    produitNom: map['produitNom'],
    quantite: map['quantite'],
    date: map['date'],
  );
}

class Demande {
  int? id;
  String bureauNom;
  String produitNom;
  int quantite;
  String date;
  DemandeStatus status;
  Demande({
    this.id,
    required this.bureauNom,
    required this.produitNom,
    required this.quantite,
    required this.date,
    this.status = DemandeStatus.enAttente,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bureauNom': bureauNom,
    'produitNom': produitNom,
    'quantite': quantite,
    'date': date,
    'status': status.toString(),
  };

  factory Demande.fromMap(Map<String, dynamic> map) {
    DemandeStatus getStatus(String s) {
      if (s.contains('acceptee')) return DemandeStatus.acceptee;
      if (s.contains('refusee')) return DemandeStatus.refusee;
      return DemandeStatus.enAttente;
    }
    return Demande(
      id: map['id'],
      bureauNom: map['bureauNom'],
      produitNom: map['produitNom'],
      quantite: map['quantite'],
      date: map['date'],
      status: getStatus(map['status']),
    );
  }
}

class AppData {
  static String? numBon; // Maintenu pour compatibilité si besoin ailleurs, mais obsolète pour la recherche
  static String? annee;
  static String? fournisseur;

  static List<Bon> allBons = [];
  static List<Produit> allProduits = [];
  static List<Bureau> listBureaux = [];
  static List<Consommation> allConsommations = [];
  static List<Demande> allDemandes = [];
}

















































