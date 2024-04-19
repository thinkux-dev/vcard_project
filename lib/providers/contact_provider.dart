import 'package:flutter/material.dart';
import 'package:vcard_project/db/db_helper.dart';
import 'package:vcard_project/models/contact_model.dart';

class ContactProvider extends ChangeNotifier{
  List<ContactModel> contactList = [];
  final db = DbHelper();

  Future<int> insertContact(ContactModel contactModel) async {
    final rowId = await db.insertContact(contactModel);
    contactModel.id = rowId;
    contactList.add(contactModel);
    notifyListeners();
    return rowId;
  }

  Future<void> getAllContacts() async {
    contactList = await db.getAllContacts();
    notifyListeners();
  }

  Future<ContactModel> getContactById(int id) => db.getContactById(id);

  Future<void> getAllFavoritesContacts() async {
    contactList = await db.getAllFavoritesContacts();
    notifyListeners();
  }

  Future<int> deleteContact(int id){
    return db.deleteContact(id);
  }

  Future<void> updateFavorite(ContactModel contactModel) async{
    final value = contactModel.favorite ? 0 : 1;
    await db.updateFavorite(contactModel.id, value);
    final index = contactList.indexOf(contactModel);
    contactList[index].favorite = !contactList[index].favorite;
    notifyListeners();
  }
}