import 'package:flutter/material.dart';
import '../models.dart';
import 'form_consommation.dart'; // تأكدي من اسم الملف عندك
import '../database_helper.dart';

class BureauxScreen extends StatefulWidget {
  @override
  _BureauxScreenState createState() => _BureauxScreenState();
}

class _BureauxScreenState extends State<BureauxScreen> {
  final nameController = TextEditingController();

  void _addBureau() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajouter un Bureau"),
        content: TextField(controller: nameController, decoration: InputDecoration(hintText: "Nom du bureau")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newBureau = Bureau(nom: nameController.text);
                await DatabaseHelper.instance.insertBureau(newBureau);
                final list = await DatabaseHelper.instance.getAllBureaux();
                if (mounted) {
                  setState(() {
                    AppData.listBureaux = list;
                  });
                  nameController.clear();
                  Navigator.pop(context);
                }
              }
            },
            child: Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // لون خلفية هادئ
      appBar: AppBar(
        title: Text("Gestion des Bureaux", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1976D2),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AppData.listBureaux.isEmpty
          ? Center(child: Text("Aucun bureau ajouté."))
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: AppData.listBureaux.length,
        itemBuilder: (context, index) {
          final bureau = AppData.listBureaux[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormConsommationScreen(bureau: bureau)),
                );
              },
              // الدائرة الزرقاء الفاتحة اللي فيها الرقم (بحال الصورة)
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("${index + 1}",
                      style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                ),
              ),
              title: Text(bureau.nom, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              // أيقونات التعديل والمسح (بحال الصورة)
              trailing: Wrap(
                spacing: 12,
                children: [
                  Icon(Icons.edit, color: Colors.blue.shade400, size: 20),
                  GestureDetector(
                    onTap: () async {
                      await DatabaseHelper.instance.deleteBureau(bureau.nom);
                      final list = await DatabaseHelper.instance.getAllBureaux();
                      setState(() => AppData.listBureaux = list);
                    },
                    child: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBureau,
        label: Text("Ajouter", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }
}