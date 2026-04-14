
import 'package:flutter/material.dart';
import '../models.dart';

class ConsommationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Historique des Sorties"), backgroundColor: Color(0xFF1976D2)),
      body: AppData.allConsommations.isEmpty
          ? Center(child: Text("Aucune sortie enregistrée."))
          : ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: AppData.allConsommations.length,
        itemBuilder: (context, index) {
          final c = AppData.allConsommations[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(Icons.outbox, color: Colors.redAccent),
              title: Text("${c.produitNom} ➔ ${c.bureauNom}"),
              subtitle: Text("Date: ${c.date}"),
              trailing: Text("-${c.quantite}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}


