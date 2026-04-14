import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestion_stock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Passage à la version 4 pour la migration
    return await openDatabase(
      path, 
      version: 4, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produits (
        designation TEXT PRIMARY KEY,
        quantite INTEGER,
        prixUnitaire REAL,
        numBon TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE bureaux (
        nom TEXT PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE consommations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bureauNom TEXT,
        produitNom TEXT,
        quantite INTEGER,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE demandes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bureauNom TEXT,
        produitNom TEXT,
        quantite INTEGER,
        date TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bons (
        numBon TEXT PRIMARY KEY,
        annee TEXT,
        fournisseur TEXT,
        objet TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE produits ADD COLUMN numBon TEXT');
      await db.execute('''
        CREATE TABLE bons (
          numBon TEXT PRIMARY KEY,
          annee TEXT,
          fournisseur TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE bons ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE bons ADD COLUMN objet TEXT');
    }
  }

  // --- BONS ---
  Future insertBon(Bon b) async {
    final db = await instance.database;
    await db.insert('bons', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Bon>> getAllBons() async {
    final db = await instance.database;
    final result = await db.query('bons');
    return result.map((json) => Bon.fromMap(json)).toList();
  }

  // --- PRODUITS ---
  Future insertProduit(Produit p) async {
    final db = await instance.database;
    await db.insert('produits', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Produit>> getAllProduits() async {
    final db = await instance.database;
    final result = await db.query('produits');
    return result.map((json) => Produit.fromMap(json)).toList();
  }

  Future clearProduits() async {
    final db = await instance.database;
    await db.delete('produits');
  }

  // --- BUREAUX ---
  Future insertBureau(Bureau b) async {
    final db = await instance.database;
    await db.insert('bureaux', b.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Bureau>> getAllBureaux() async {
    final db = await instance.database;
    final result = await db.query('bureaux');
    return result.map((json) => Bureau.fromMap(json)).toList();
  }

  Future deleteBureau(String nom) async {
    final db = await instance.database;
    await db.delete('bureaux', where: 'nom = ?', whereArgs: [nom]);
  }

  // --- CONSOMMATIONS ---
  Future<int> insertConsommation(Consommation c) async {
    final db = await instance.database;
    Map<String, dynamic> row = c.toMap();
    row.remove('id'); // l'id est null et sera auto-incrémenté
    return await db.insert('consommations', row);
  }

  Future<List<Consommation>> getAllConsommations() async {
    final db = await instance.database;
    final result = await db.query('consommations');
    return result.map((json) => Consommation.fromMap(json)).toList();
  }

  // --- DEMANDES ---
  Future<int> insertDemande(Demande d) async {
    final db = await instance.database;
    Map<String, dynamic> row = d.toMap();
    row.remove('id'); // l'id est null et sera auto-incrémenté
    return await db.insert('demandes', row);
  }

  Future updateDemandeStatus(int id, DemandeStatus status) async {
    final db = await instance.database;
    await db.update('demandes', {'status': status.toString()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Demande>> getAllDemandes() async {
    final db = await instance.database;
    final result = await db.query('demandes');
    return result.map((json) => Demande.fromMap(json)).toList();
  }
}