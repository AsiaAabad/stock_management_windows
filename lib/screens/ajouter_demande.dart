import 'package:flutter/material.dart';
import '../models.dart';
import '../database_helper.dart';

class AjouterDemandeScreen extends StatefulWidget {
  @override
  _AjouterDemandeScreenState createState() => _AjouterDemandeScreenState();
}

class _AjouterDemandeScreenState extends State<AjouterDemandeScreen> {
  String? selBureau;
  String? selProduit;
  final qteCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: "31/03/2026");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle Demande")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "🏢 Sélectionner Bureau"),
              items: AppData.listBureaux.map((b) => DropdownMenuItem(value: b.nom, child: Text(b.nom))).toList(),
              onChanged: (v) => selBureau = v,
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "📦 Sélectionner Produit"),
              items: AppData.allProduits.map((p) => DropdownMenuItem(value: p.designation, child: Text(p.designation))).toList(),
              onChanged: (v) => selProduit = v,
            ),
            SizedBox(height: 15),
            TextField(controller: qteCtrl, decoration: InputDecoration(labelText: "🔢 Quantité"), keyboardType: TextInputType.number),
            SizedBox(height: 15),
            TextField(controller: dateCtrl, decoration: InputDecoration(labelText: "📅 Date")),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 50)),
              onPressed: () async {
                if (selBureau != null && selProduit != null && qteCtrl.text.isNotEmpty) {
                  final newDemande = Demande(
                    bureauNom: selBureau!,
                    produitNom: selProduit!,
                    quantite: int.parse(qteCtrl.text),
                    date: dateCtrl.text,
                  );
                  await DatabaseHelper.instance.insertDemande(newDemande);
                  final list = await DatabaseHelper.instance.getAllDemandes();
                  
                  if (mounted) {
                    setState(() {
                      AppData.allDemandes = list;
                    });
                    Navigator.pop(context);
                  }
                }
              },
              child: Text("VALIDER LA DEMANDE"),
            )
          ],
        ),
      ),
    );
  }
}