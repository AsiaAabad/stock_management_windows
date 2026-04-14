
import 'package:flutter/material.dart';
import 'models.dart';
import 'screens/demandes_list.dart';
import 'screens/ajouter_bon.dart';
import 'screens/rechercher.dart';
import 'screens/stock.dart';
import 'screens/bureaux.dart';
import 'screens/consommation.dart';
import 'screens/statistiques.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // حساب الإحصائيات الفوق
    int totalUnits = AppData.allProduits.fold(0, (sum, item) => sum + item.quantite);
    int nbBureaux = AppData.listBureaux.length;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Gestion de Commande",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF1976D2),
        elevation: 2,
      ),
      body: Column(
        children: [
          // القسم العلوي: الإحصائيات
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _statHeaderCard("Stock Total", "$totalUnits", Colors.blue),
                    SizedBox(width: 15),
                    _statHeaderCard("Bureaux", "$nbBureaux", Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),

          // القسم السفلي: القائمة بالأزرار البيضاء (كيف كانت)
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _actionBtn(context, "Gestion Demandes", Icons.mail_outline, Colors.orange, DemandesListScreen()),
                _actionBtn(context, "Ajouter Bon", Icons.add_circle, Colors.green, AjouterBonScreen()),
                _actionBtn(context, "Rechercher Bon", Icons.search, Color(0xFF1976D2), RechercherScreen()),
                _actionBtn(context, "Stock", Icons.inventory_2, Colors.blue, StockScreen()),
                _actionBtn(context, "Consommation", Icons.analytics, Colors.redAccent, ConsommationScreen()),
                _actionBtn(context, "Bureaux", Icons.business, Colors.teal, BureauxScreen()),
                _actionBtn(context, "Statistiques", Icons.pie_chart, Colors.indigo, StatistiquesScreen()),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statHeaderCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // هاد الـ Widget هو اللي كيعطي الديزاين القديم للأزرار
  Widget _actionBtn(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 1,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen)).then((_) {
            setState(() {}); // باش يتحدثوا الأرقام ملي نرجعوا
          });
        },
        child: Row(
          children: [
            Icon(icon, size: 26),
            SizedBox(width: 15),
            Text(title, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
