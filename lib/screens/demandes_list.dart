
import 'package:flutter/material.dart';
import '../models.dart';
import 'ajouter_demande.dart';
import '../database_helper.dart';

class DemandesListScreen extends StatefulWidget {
  @override
  _DemandesListScreenState createState() => _DemandesListScreenState();
}

class _DemandesListScreenState extends State<DemandesListScreen> {

  Color _getStatusColor(DemandeStatus status) {
    switch (status) {
      case DemandeStatus.enAttente: return Colors.orange;
      case DemandeStatus.acceptee: return Colors.green;
      case DemandeStatus.refusee: return Colors.red;
    }
  }

  void _traiterDemande(Demande d) {
    if (d.status != DemandeStatus.enAttente) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Traitement de la demande", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("${d.bureauNom} demande ${d.quantite}x ${d.produitNom}"),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () async {
                      if (d.id != null) {
                        await DatabaseHelper.instance.updateDemandeStatus(d.id!, DemandeStatus.refusee);
                        final list = await DatabaseHelper.instance.getAllDemandes();
                        if (mounted) setState(() => AppData.allDemandes = list);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text("REFUSER"),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () async {
                      if (d.id != null) {
                        await DatabaseHelper.instance.updateDemandeStatus(d.id!, DemandeStatus.acceptee);
                        final newConsommation = Consommation(
                          bureauNom: d.bureauNom,
                          produitNom: d.produitNom,
                          quantite: d.quantite,
                          date: d.date,
                        );
                        await DatabaseHelper.instance.insertConsommation(newConsommation);
                        
                        final demandes = await DatabaseHelper.instance.getAllDemandes();
                        final consommations = await DatabaseHelper.instance.getAllConsommations();
                        
                        if (mounted) {
                          setState(() {
                            AppData.allDemandes = demandes;
                            AppData.allConsommations = consommations;
                          });
                        }
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text("ACCEPTER"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Demandes"), backgroundColor: Color(0xFF1976D2)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add_comment),
              label: Text("Ajouter Demande"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AjouterDemandeScreen())).then((_) => setState((){})),
            ),
          ),
          Expanded(
            child: AppData.allDemandes.isEmpty
                ? Center(child: Text("Aucune demande pour le moment."))
                : ListView.builder(
              itemCount: AppData.allDemandes.length,
              itemBuilder: (context, index) {
                final d = AppData.allDemandes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  child: ListTile(
                    onTap: () => _traiterDemande(d),
                    leading: Icon(Icons.description, color: _getStatusColor(d.status)),
                    title: Text("${d.bureauNom} - ${d.produitNom}", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Qte: ${d.quantite} | Date: ${d.date}"),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getStatusColor(d.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        d.status == DemandeStatus.enAttente ? "En attente" :
                        d.status == DemandeStatus.acceptee ? "Acceptée" : "Refusée",
                        style: TextStyle(color: _getStatusColor(d.status), fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
