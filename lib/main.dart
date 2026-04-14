import 'package:flutter/material.dart';
import 'dashboard.dart'; // الملف اللي فيه القائمة الرئيسية
import 'models.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load data from SQLite
  AppData.allBons = await DatabaseHelper.instance.getAllBons();
  AppData.allProduits = await DatabaseHelper.instance.getAllProduits();
  AppData.listBureaux = await DatabaseHelper.instance.getAllBureaux();
  AppData.allConsommations = await DatabaseHelper.instance.getAllConsommations();
  AppData.allDemandes = await DatabaseHelper.instance.getAllDemandes();

  runApp(GestionApp());
}

class GestionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Stocks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: DashboardScreen(), // نقطة الانطلاق
    );
  }
}
