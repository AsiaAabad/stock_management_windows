
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models.dart';

class StatistiquesScreen extends StatefulWidget {
  @override
  _StatistiquesScreenState createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> {
  String? selectedBureauFilter;
  String? selectedProduitFilter;

  @override
  void initState() {
    super.initState();
    selectedBureauFilter = "Tous les bureaux";
    selectedProduitFilter = "Tous les produits";
  }

  @override
  Widget build(BuildContext context) {
    List<String> bureauxFiltres = ["Tous les bureaux"];
    bureauxFiltres.addAll(AppData.allConsommations.map((c) => c.bureauNom).toSet().toList());

    List<String> produitsFiltres = ["Tous les produits"];
    produitsFiltres.addAll(AppData.allConsommations.map((c) => c.produitNom).toSet().toList());

    // Vérifier si le filtre sélectionné existe toujours, sinon remettre par défaut
    if (!bureauxFiltres.contains(selectedBureauFilter)) selectedBureauFilter = "Tous les bureaux";
    if (!produitsFiltres.contains(selectedProduitFilter)) selectedProduitFilter = "Tous les produits";

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Statistiques", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildChartCard(
                title: "Consommation par Produit (%)",
                chart: Column(
                  children: [
                    _buildDropdown(
                      value: selectedBureauFilter,
                      items: bureauxFiltres,
                      onChanged: (val) => setState(() => selectedBureauFilter = val),
                    ),
                    Container(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: _generateProduitPieSections(selectedBureauFilter!),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildProduitLegend(selectedBureauFilter!),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildChartCard(
                title: "Répartition par Bureau (%)",
                chart: Column(
                  children: [
                    _buildDropdown(
                      value: selectedProduitFilter,
                      items: produitsFiltres,
                      onChanged: (val) => setState(() => selectedProduitFilter = val),
                    ),
                    Container(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: _generateBureauPieSections(selectedProduitFilter!),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildBureauLegend(selectedProduitFilter!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0D47A1)),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- توليد بيانات الدائرة مع النسب المئوية (Produits) ---
  List<PieChartSectionData> _generateProduitPieSections(String filtreBureau) {
    Map<String, int> stats = {};
    int total = 0;

    for (var c in AppData.allConsommations) {
      if (filtreBureau == "Tous les bureaux" || c.bureauNom == filtreBureau) {
        stats[c.produitNom] = (stats[c.produitNom] ?? 0) + c.quantite;
        total += c.quantite;
      }
    }

    if (stats.isEmpty) {
      return [PieChartSectionData(value: 1, title: "0%", color: Colors.grey, radius: 80)];
    }

    List<Color> colors = [Colors.blue, Colors.orange, Colors.red, Colors.green, Colors.purple, Colors.teal];
    int i = 0;

    return stats.entries.map((entry) {
      final double percentage = (entry.value / total) * 100;
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // --- ويدجت مفتاح الألوان (Produits) ---
  Widget _buildProduitLegend(String filtreBureau) {
    Map<String, int> stats = {};
    for (var c in AppData.allConsommations) {
      if (filtreBureau == "Tous les bureaux" || c.bureauNom == filtreBureau) {
        stats[c.produitNom] = (stats[c.produitNom] ?? 0) + c.quantite;
      }
    }

    List<Color> colors = [Colors.blue, Colors.orange, Colors.red, Colors.green, Colors.purple, Colors.teal];
    int i = 0;

    return Wrap(
      spacing: 20,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: stats.keys.map((name) {
        final color = colors[i % colors.length];
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        );
      }).toList(),
    );
  }

  // --- توليد بيانات الدائرة (Bureaux) ---
  List<PieChartSectionData> _generateBureauPieSections(String filtreProduit) {
    Map<String, int> stats = {};
    int total = 0;

    for (var c in AppData.allConsommations) {
      if (filtreProduit == "Tous les produits" || c.produitNom == filtreProduit) {
        stats[c.bureauNom] = (stats[c.bureauNom] ?? 0) + c.quantite;
        total += c.quantite;
      }
    }

    if (stats.isEmpty) {
      return [PieChartSectionData(value: 1, title: "0%", color: Colors.grey, radius: 80)];
    }

    List<Color> colors = [Colors.teal, Colors.amber, Colors.pink, Colors.indigo, Colors.cyan, Colors.deepOrange];
    int i = 0;

    return stats.entries.map((entry) {
      final double percentage = (entry.value / total) * 100;
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // --- ويدجت مفتاح الألوان (Bureaux) ---
  Widget _buildBureauLegend(String filtreProduit) {
    Map<String, int> stats = {};
    for (var c in AppData.allConsommations) {
      if (filtreProduit == "Tous les produits" || c.produitNom == filtreProduit) {
        stats[c.bureauNom] = (stats[c.bureauNom] ?? 0) + c.quantite;
      }
    }

    List<Color> colors = [Colors.teal, Colors.amber, Colors.pink, Colors.indigo, Colors.cyan, Colors.deepOrange];
    int i = 0;

    return Wrap(
      spacing: 20,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: stats.keys.map((name) {
        final color = colors[i % colors.length];
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)), textAlign: TextAlign.center),
          SizedBox(height: 25),
          chart,
        ],
      ),
    );
  }
}
