import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models.dart';
import '../database_helper.dart';

class AjouterBonScreen extends StatefulWidget {
  @override
  _AjouterBonScreenState createState() => _AjouterBonScreenState();
}

class _AjouterBonScreenState extends State<AjouterBonScreen> {
  final nBonController = TextEditingController();
  final anneeController = TextEditingController();
  final fournisseurController = TextEditingController();
  final objetController = TextEditingController();

  final desController = TextEditingController();
  final qteController = TextEditingController();
  final prixController = TextEditingController();

  List<Produit> tempProduits = [];
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name = p.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$name');
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  void _ajouterAuTableau() {
    if (desController.text.isNotEmpty && qteController.text.isNotEmpty && prixController.text.isNotEmpty && nBonController.text.isNotEmpty) {
      setState(() {
        tempProduits.add(Produit(
          designation: desController.text,
          quantite: int.parse(qteController.text),
          prixUnitaire: double.parse(prixController.text),
          numBon: nBonController.text, // On attache le produit au numBon saisi
        ));
        desController.clear();
        qteController.clear();
        prixController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez saisir le numéro du bon avant d'ajouter des produits"), backgroundColor: Colors.orange),
      );
    }
  }

  // الدالة المعدلة باش تظهر الرسالة
  void _validerLeBonGlobal() async {
    if (tempProduits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez ajouter au moins un produit au tableau"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (nBonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez saisir le numéro du bon"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Création et sauvegarde du Bon
    final newBon = Bon(
      numBon: nBonController.text,
      annee: anneeController.text,
      fournisseur: fournisseurController.text,
      objet: objetController.text,
      imagePath: _imageFile?.path,
    );
    await DatabaseHelper.instance.insertBon(newBon);

    // Sauvegarde en base de données de chaque produit
    for (var p in tempProduits) {
      // Sécurité (au cas où il a été fait sans numéro)
      if (p.numBon == null || p.numBon!.isEmpty) {
        p.numBon = nBonController.text;
      }
      await DatabaseHelper.instance.insertProduit(p);
    }

    // Refresh memory from database
    final updatedBons = await DatabaseHelper.instance.getAllBons();
    final updatedProducts = await DatabaseHelper.instance.getAllProduits();
    
    if (mounted) {
      setState(() {
        AppData.numBon = nBonController.text;
        AppData.annee = anneeController.text;
        AppData.fournisseur = fournisseurController.text;
        AppData.allBons = updatedBons;
        AppData.allProduits = updatedProducts;
      });

      // إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Bon de commande enregistré avec succès !"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // الرجوع للـ Dashboard بعد ثانية واحدة باش يشوف المستخدم الرسالة
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Ajouter Bon", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1976D2),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Informations du Bon"),
            _buildCustomField("Numéro Bon", nBonController),
            _buildCustomField("Année", anneeController),
            _buildCustomField("Fournisseur", fournisseurController),
            _buildCustomField("Objet", objetController),

            SizedBox(height: 25),
            Divider(thickness: 1),
            SizedBox(height: 10),

            _sectionTitle("Détails du Produit"),
            _buildCustomField("Désignation Produit", desController),
            Row(
              children: [
                Expanded(child: _buildCustomField("Quantité", qteController, isNumber: true)),
                SizedBox(width: 15),
                Expanded(child: _buildCustomField("Prix Unitaire", prixController, isNumber: true)),
              ],
            ),

            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _ajouterAuTableau,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF607D8B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("+ Ajouter au tableau", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 30),

            if (tempProduits.isNotEmpty) ...[
              _sectionTitle("Produits ajoutés"),
              _buildPreviewTable(),
              SizedBox(height: 30),
            ],

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                label: Text("Scanner document", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            if (_imageFile != null) ...[
              SizedBox(height: 15),
              Text("Document scanné:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 15),
            ] else SizedBox(height: 30),

            // --- الزر الأخضر مع الرسالة ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _validerLeBonGlobal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // اللون الأخضر
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("VALIDER LE BON", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
    );
  }

  Widget _buildCustomField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Table(
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: ["Item", "Qte", "Total"].map((h) => Padding(padding: EdgeInsets.all(10), child: Text(h, style: TextStyle(fontWeight: FontWeight.bold)))).toList(),
          ),
          ...tempProduits.map((p) => TableRow(
            children: [
              Padding(padding: EdgeInsets.all(10), child: Text(p.designation)),
              Padding(padding: EdgeInsets.all(10), child: Text("${p.quantite}")),
              Padding(padding: EdgeInsets.all(10), child: Text("${p.totalTTC.toStringAsFixed(1)}")),
            ],
          )),
        ],
      ),
    );
  }
}