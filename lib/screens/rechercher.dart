import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models.dart';

class RechercherScreen extends StatefulWidget {
  @override
  _RechercherScreenState createState() => _RechercherScreenState();
}

class _RechercherScreenState extends State<RechercherScreen> {
  final searchCtrl = TextEditingController();
  Bon? foundBon;
  List<Produit> foundProduits = [];

  void _chercher() {
    setState(() {
      try {
        foundBon = AppData.allBons.firstWhere((b) => b.numBon == searchCtrl.text);
        if (foundBon != null) {
          foundProduits = AppData.allProduits.where((p) => p.numBon == foundBon!.numBon).toList();
        } else {
          foundProduits = [];
        }
      } catch (e) {
        foundBon = null;
        foundProduits = [];
      }
    });
  }

  Future<pw.Document> _generatePdfDoc() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("BON DE COMMANDE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text("N° Bon : ${foundBon!.numBon}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Année : ${foundBon!.annee}", style: const pw.TextStyle(fontSize: 16)),
              pw.Text("Fournisseur : ${foundBon!.fournisseur}", style: const pw.TextStyle(fontSize: 16)),
              if (foundBon!.objet != null && foundBon!.objet!.isNotEmpty)
                pw.Text("Objet : ${foundBon!.objet}", style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                headers: ['Désignation', 'Qté', 'Total TTC'],
                data: foundProduits.map((p) => [
                  p.designation, 
                  p.quantite.toString(), 
                  p.totalTTC.toStringAsFixed(2)]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total Global: ${foundProduits.fold(0.0, (sum, p) => sum + p.totalTTC).toStringAsFixed(2)} MAD", 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  void _openPdfPreview() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text("Aperçu PDF", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1976D2), iconTheme: IconThemeData(color: Colors.white)),
        body: PdfPreview(
          build: (format) async {
            final doc = await _generatePdfDoc();
            return doc.save();
          },
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Rechercher Bon", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1976D2)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: searchCtrl, decoration: InputDecoration(hintText: "N° Bon", border: OutlineInputBorder()))),
            SizedBox(width: 10),
            ElevatedButton(onPressed: _chercher, child: Text("Chercher")),
          ]),
          SizedBox(height: 30),

          if (foundBon == null) Center(child: Text("Aucun résultat trouvé (Veuillez valider un Bon d'abord)"))
          else ...[
            Text("Bon N° ${foundBon!.numBon}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            Divider(),
            Text("Fournisseur : ${foundBon!.fournisseur}"),
            Text("Année : ${foundBon!.annee}"),
            if (foundBon!.objet != null && foundBon!.objet!.isNotEmpty)
              Text("Objet : ${foundBon!.objet}"),
            SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openPdfPreview,
                icon: Icon(Icons.print, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                label: Text("Imprimer Bon / Exporter PDF", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            SizedBox(height: 20),
            _buildTable(),
            if (foundBon!.imagePath != null) ...[
              SizedBox(height: 30),
              Text("Document scanné:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: InteractiveViewer(
                        child: Image.file(File(foundBon!.imagePath!)),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(foundBon!.imagePath!), height: 250, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ]
          ]
        ]),
      ),
    );
  }

  Widget _buildTable() => Table(
    border: TableBorder.all(color: Colors.grey.shade300),
    children: [
      TableRow(decoration: BoxDecoration(color: Colors.grey.shade100), children: ["Désignation", "Qté", "TTC"].map((h)=>Padding(padding: EdgeInsets.all(8), child: Text(h, style: TextStyle(fontWeight: FontWeight.bold)))).toList()),
      ...foundProduits.map((p) => TableRow(children: [p.designation, "${p.quantite}", "${p.totalTTC.toStringAsFixed(2)}"].map((c)=>Padding(padding: EdgeInsets.all(8), child: Text(c))).toList())),
    ],
  );
}