import 'package:flutter/material.dart';
import '../models.dart';
import '../database_helper.dart';

class FormConsommationScreen extends StatefulWidget {
  final Bureau bureau;
  FormConsommationScreen({required this.bureau});

  @override
  _FormConsommationScreenState createState() => _FormConsommationScreenState();
}

class _FormConsommationScreenState extends State<FormConsommationScreen> {
  String? selectedProduit;
  final quantiteController = TextEditingController();
  final dateController = TextEditingController(text: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}");

  void _validerConsommation() async {
    if (selectedProduit != null && quantiteController.text.isNotEmpty) {
      final newConsommation = Consommation(
        bureauNom: widget.bureau.nom,
        produitNom: selectedProduit!,
        quantite: int.parse(quantiteController.text),
        date: dateController.text,
      );
      await DatabaseHelper.instance.insertConsommation(newConsommation);
      final list = await DatabaseHelper.instance.getAllConsommations();
      
      if (mounted) {
        setState(() {
          AppData.allConsommations = list;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sortie enregistrée !"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sortie : ${widget.bureau.nom}"),
        backgroundColor: Color(0xFF1976D2),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Produit", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // القائمة المنسدلة فيها السلعة اللي دخلنا فـ Ajouter Bon
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              value: selectedProduit,
              hint: Text("Sélectionner un produit"),
              items: AppData.allProduits.map((p) => DropdownMenuItem(
                  value: p.designation,
                  child: Text(p.designation)
              )).toList(),
              onChanged: (val) => setState(() => selectedProduit = val),
            ),
            SizedBox(height: 20),
            Text("Quantité", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: "0"),
            ),
            SizedBox(height: 20),
            Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: dateController,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), suffixIcon: Icon(Icons.calendar_today)),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _validerConsommation,
                child: Text("VALIDER LA SORTIE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
