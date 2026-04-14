import 'package:flutter/material.dart';
import '../models.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("État du Stock"), backgroundColor: Color(0xFF1976D2)),
      body: AppData.allProduits.isEmpty
          ? Center(child: Text("Stock vide. Ajoutez un bon d'achat."))
          : ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: AppData.allProduits.length,
        itemBuilder: (context, index) {
          final p = AppData.allProduits[index];

          // حساب الاستهلاك الخاص بهذا المنتج
          int consomme = AppData.allConsommations
              .where((c) => c.produitNom == p.designation)
              .fold(0, (sum, c) => sum + c.quantite);

          int reste = p.quantite - consomme;

          return Card(
            elevation: 3,
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p.designation, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Initial: ${p.quantite} | Sortie: $consomme"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$reste", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: reste > 5 ? Colors.green : Colors.red)),
                  Text("En Stock", style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}