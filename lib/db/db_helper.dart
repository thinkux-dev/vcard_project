import 'package:path/path.dart' as P;
import 'package:sqflite/sqflite.dart';
import 'package:vcard_project/models/contact_model.dart';

class DbHelper {
  final String _createTableContact = '''create table $tableContact(
    $tblContactColId integer primary key autoincrement,
    $tblContactColName text,
    $tblContactColMobile text,
    $tblContactColEmail text,
    $tblContactColDesignation text,
    $tblContactColCompany text,
    $tblContactColAddress text,
    $tblContactColWebsite text,
    $tblContactColImage text,
    $tblContactColFavorite integer)''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = P.join(root, 'contact.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) {
        db.execute(_createTableContact);
      },
      // Database Migration
      onUpgrade: (db, oldVersion, newVersion) async {
        if(oldVersion == 1) {
          await db.execute('alter table $tableContact rename to ${'contact_old'}');
          db.execute(_createTableContact);
          // copy data from old table to new table
          final rows = await db.query('contact_old');
          for(var row in rows) {
            await db.insert(tableContact, row);
          }
          await db.execute('drop table if exists ${'contact_old'}');
        }
      }
    );
  }

  Future<int> insertContact(ContactModel contactModel) async {
    final db = await _open();
    return db.insert(tableContact, contactModel.toMap(), );
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact,);
    return List.generate(
        mapList.length, (index) => ContactModel.fromMap(mapList[index])
    );
  }

  Future<ContactModel> getContactById(int id) async {
    final db = await _open();
    final mapList = await db.query(tableContact, where: '$tblContactColId = ?', whereArgs: [id]);
    return ContactModel.fromMap(mapList.first);
  }

  Future<List<ContactModel>> getAllFavoritesContacts() async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColFavorite = ?',
      whereArgs: [1]
    );
    return List.generate(
        mapList.length, (index) => ContactModel.fromMap(mapList[index]),
    );
  }

  Future<int> updateContactField(int id, Map<String, dynamic> map) async {
    final db = await _open();
    return await db.update(
      tableContact,
      map,
      where: '$tblContactColId = ?', whereArgs: [id]
    );
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _open();
    return db.update(
      tableContact,
      {tblContactColFavorite : value},
      where: '$tblContactColId = ?', whereArgs: [id]

    );
  }

  Future<int> deleteContact(int id) async {
    final db = await _open();
    return await db.delete(
        tableContact,
        where: '$tblContactColId = ?', whereArgs: [id]
    );
  }
}